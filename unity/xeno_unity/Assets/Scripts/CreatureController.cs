using UnityEngine;

/// <summary>
/// Creature visual controller for XenoMirror OS
///
/// Receives messages from Flutter and triggers visual feedback:
/// - OnReaction: Trigger glow/particles when habit logged
/// - OnEvolution: Swap tier materials when creature evolves
/// - OnStateUpdate: Update shader glow intensity based on XP progress
/// - OnTierSync: Sync all tier visuals on app start
///
/// This script should be attached to a GameObject named "CreatureController"
/// in the Unity scene hierarchy.
/// </summary>
public class CreatureController : MonoBehaviour
{
    [Header("Body Part Renderers")]
    [Tooltip("Assign the Renderer component for the legs body part")]
    public Renderer legsRenderer;

    [Tooltip("Assign the Renderer component for the head body part")]
    public Renderer headRenderer;

    [Tooltip("Assign the Renderer component for the arms body part")]
    public Renderer armsRenderer;

    [Header("Tier Materials (Tier 0-3)")]
    [Tooltip("Materials for legs tiers 0-3")]
    public Material[] legsTierMaterials = new Material[4];

    [Tooltip("Materials for head tiers 0-3")]
    public Material[] headTierMaterials = new Material[4];

    [Tooltip("Materials for arms tiers 0-3")]
    public Material[] armsTierMaterials = new Material[4];

    [Header("Reaction Colors")]
    public Color vitalityColor = new Color(0f, 1f, 0.255f); // #00FF41
    public Color mindColor = new Color(0f, 0.953f, 1f);     // #00F3FF
    public Color soulColor = new Color(0.737f, 0.075f, 0.996f); // #BC13FE

    [Header("Shader Properties")]
    [Tooltip("Name of the shader property for glow intensity (e.g., '_GlowIntensity')")]
    public string glowIntensityProperty = "_GlowIntensity";

    [Tooltip("Name of the shader property for emission color (e.g., '_EmissionColor')")]
    public string emissionColorProperty = "_EmissionColor";

    // Current tier values (synced from Flutter)
    private int currentLegsTier = 0;
    private int currentHeadTier = 0;
    private int currentArmsTier = 0;

    // Current progress values (0.0-1.0)
    private float vitalityProgress = 0f;
    private float mindProgress = 0f;
    private float soulProgress = 0f;

    void Start()
    {
        Debug.Log("CreatureController initialized - Ready to receive messages from Flutter");

        // Set initial tier materials
        UpdateTierMaterial(legsRenderer, legsTierMaterials, currentLegsTier);
        UpdateTierMaterial(headRenderer, headTierMaterials, currentHeadTier);
        UpdateTierMaterial(armsRenderer, armsTierMaterials, currentArmsTier);
    }

    /// <summary>
    /// Called from Flutter when user logs a habit
    /// Triggers visual reaction (glow pulse) in the attribute's color
    /// </summary>
    /// <param name="attribute">"vitality", "mind", or "soul"</param>
    public void OnReaction(string attribute)
    {
        Debug.Log($"[CreatureController] Reaction triggered: {attribute}");

        Color reactionColor = GetAttributeColor(attribute);
        Renderer targetRenderer = GetRendererForAttribute(attribute);

        if (targetRenderer != null)
        {
            // Trigger glow pulse animation
            StartCoroutine(GlowPulse(targetRenderer, reactionColor, 1.0f));
        }
    }

    /// <summary>
    /// Called from Flutter when creature tier increases
    /// Swaps material to show visual evolution
    /// </summary>
    /// <param name="data">Format: "legs:2", "head:3", "arms:1"</param>
    public void OnEvolution(string data)
    {
        Debug.Log($"[CreatureController] Evolution triggered: {data}");

        string[] parts = data.Split(':');
        if (parts.Length != 2)
        {
            Debug.LogError($"Invalid evolution data format: {data}");
            return;
        }

        string bodyPart = parts[0];
        int newTier = int.Parse(parts[1]);

        // Update tier and swap material
        switch (bodyPart)
        {
            case "legs":
                currentLegsTier = newTier;
                UpdateTierMaterial(legsRenderer, legsTierMaterials, newTier);
                break;
            case "head":
                currentHeadTier = newTier;
                UpdateTierMaterial(headRenderer, headTierMaterials, newTier);
                break;
            case "arms":
                currentArmsTier = newTier;
                UpdateTierMaterial(armsRenderer, armsTierMaterials, newTier);
                break;
            default:
                Debug.LogWarning($"Unknown body part: {bodyPart}");
                break;
        }

        // TODO: Trigger evolution particle effect
    }

    /// <summary>
    /// Called from Flutter to sync XP progress for shader glow
    /// </summary>
    /// <param name="data">Format: "0.5,0.8,0.3" (CSV: vitality,mind,soul progress 0-1)</param>
    public void OnStateUpdate(string data)
    {
        Debug.Log($"[CreatureController] State update: {data}");

        string[] values = data.Split(',');
        if (values.Length != 3)
        {
            Debug.LogError($"Invalid state data format: {data}");
            return;
        }

        vitalityProgress = float.Parse(values[0]);
        mindProgress = float.Parse(values[1]);
        soulProgress = float.Parse(values[2]);

        // Update shader glow intensities
        UpdateShaderGlow(legsRenderer, vitalityProgress, vitalityColor);
        UpdateShaderGlow(headRenderer, mindProgress, mindColor);
        UpdateShaderGlow(armsRenderer, soulProgress, soulColor);
    }

    /// <summary>
    /// Called from Flutter on app start to sync all tier visuals
    /// </summary>
    /// <param name="data">Format: "legs:1,head:2,arms:0"</param>
    public void OnTierSync(string data)
    {
        Debug.Log($"[CreatureController] Tier sync: {data}");

        string[] parts = data.Split(',');
        foreach (string part in parts)
        {
            string[] kv = part.Split(':');
            if (kv.Length == 2)
            {
                string bodyPart = kv[0];
                int tier = int.Parse(kv[1]);

                switch (bodyPart)
                {
                    case "legs":
                        currentLegsTier = tier;
                        UpdateTierMaterial(legsRenderer, legsTierMaterials, tier);
                        break;
                    case "head":
                        currentHeadTier = tier;
                        UpdateTierMaterial(headRenderer, headTierMaterials, tier);
                        break;
                    case "arms":
                        currentArmsTier = tier;
                        UpdateTierMaterial(armsRenderer, armsTierMaterials, tier);
                        break;
                }
            }
        }
    }

    // ===== HELPER METHODS =====

    private Color GetAttributeColor(string attribute)
    {
        switch (attribute.ToLower())
        {
            case "vitality":
                return vitalityColor;
            case "mind":
                return mindColor;
            case "soul":
                return soulColor;
            default:
                return Color.white;
        }
    }

    private Renderer GetRendererForAttribute(string attribute)
    {
        switch (attribute.ToLower())
        {
            case "vitality":
                return legsRenderer;
            case "mind":
                return headRenderer;
            case "soul":
                return armsRenderer;
            default:
                return null;
        }
    }

    private void UpdateTierMaterial(Renderer renderer, Material[] materials, int tier)
    {
        if (renderer == null || materials == null || tier < 0 || tier >= materials.Length)
        {
            Debug.LogWarning($"Cannot update tier material: renderer={renderer}, tier={tier}");
            return;
        }

        renderer.material = materials[tier];
        Debug.Log($"Material updated to tier {tier}");
    }

    private void UpdateShaderGlow(Renderer renderer, float progress, Color glowColor)
    {
        if (renderer == null || renderer.material == null)
        {
            return;
        }

        Material mat = renderer.material;

        // Update glow intensity (0.0 - 1.0)
        if (mat.HasProperty(glowIntensityProperty))
        {
            mat.SetFloat(glowIntensityProperty, progress);
        }

        // Update emission color
        if (mat.HasProperty(emissionColorProperty))
        {
            Color emissionColor = glowColor * progress;
            mat.SetColor(emissionColorProperty, emissionColor);
        }
    }

    private System.Collections.IEnumerator GlowPulse(Renderer renderer, Color color, float duration)
    {
        if (renderer == null || renderer.material == null)
        {
            yield break;
        }

        Material mat = renderer.material;
        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float intensity = Mathf.Sin(elapsed * Mathf.PI / duration); // 0 -> 1 -> 0

            if (mat.HasProperty(emissionColorProperty))
            {
                Color emissionColor = color * intensity * 2f; // 2x brightness
                mat.SetColor(emissionColorProperty, emissionColor);
            }

            yield return null;
        }

        // Reset to normal glow based on progress
        float normalProgress = 0f;
        if (renderer == legsRenderer) normalProgress = vitalityProgress;
        else if (renderer == headRenderer) normalProgress = mindProgress;
        else if (renderer == armsRenderer) normalProgress = soulProgress;

        UpdateShaderGlow(renderer, normalProgress, color);
    }
}
