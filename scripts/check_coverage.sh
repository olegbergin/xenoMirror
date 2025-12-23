#!/bin/bash
# Generate coverage report and check threshold
# Usage: bash scripts/check_coverage.sh

echo "🧪 Running tests with coverage..."
flutter test --coverage

if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Fix failing tests first."
  exit 1
fi

echo ""
echo "📊 Coverage Summary:"
echo "-------------------"

# Check if lcov is available (install: choco install lcov on Windows)
if command -v lcov &> /dev/null; then
  lcov --summary coverage/lcov.info

  # Extract coverage percentage (requires bc for float comparison)
  if command -v bc &> /dev/null; then
    COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | sed 's/.*: //' | sed 's/%.*//')

    echo ""
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "❌ Coverage is ${COVERAGE}%, below 80% threshold"
      exit 1
    else
      echo "✅ Coverage is ${COVERAGE}%, meets threshold"
      exit 0
    fi
  else
    echo "⚠️  'bc' not installed. Cannot check coverage threshold."
    echo "   Install with: choco install bc (Windows) or apt-get install bc (Linux)"
  fi
else
  echo "⚠️  lcov not installed. Install with:"
  echo "   Windows: choco install lcov"
  echo "   Linux: apt-get install lcov"
  echo "   macOS: brew install lcov"
  echo ""
  echo "📄 Coverage report generated at: coverage/lcov.info"
  echo "   To view HTML report, install lcov and run:"
  echo "   genhtml coverage/lcov.info -o coverage/html"
  echo "   Then open coverage/html/index.html in browser"
fi
