/**
 * Custom Tolgee extractor for Vue/JS files
 * Extracts translation keys from $t(), t(), and $tc() calls
 */

const TRANSLATION_PATTERNS = [
  // $t('key') or $t("key") - Vue template/options API
  /\$t\(\s*['"`]([^'"`]+)['"`]\s*(?:,|\))/g,
  // t('key') or t("key") - Composition API
  /(?<![.\w])t\(\s*['"`]([^'"`]+)['"`]\s*(?:,|\))/g,
  // $tc('key') - pluralization
  /\$tc\(\s*['"`]([^'"`]+)['"`]\s*(?:,|\))/g,
  // tc('key') - pluralization composition API
  /(?<![.\w])tc\(\s*['"`]([^'"`]+)['"`]\s*(?:,|\))/g,
  // <i18n-t keypath="key"> - Vue i18n component
  /<i18n-t[^>]*\skeypath=['"]([^'"]+)['"]/g,
  // __('mixpost::key') - Laravel PHP translation
  /__\(\s*['"]mixpost::([^'"]+)['"]\s*(?:,|\))/g,
];

/**
 * Tolgee custom extractor
 * @param {string} code - File content
 * @param {string} fileName - File name
 * @returns {{ keys: Array<{ keyName: string; line: number; defaultValue?: string; namespace?: string }> }}
 */
function extract(code, fileName) {
  const keys = [];

  if (!code || typeof code !== 'string') {
    return { keys };
  }

  for (const pattern of TRANSLATION_PATTERNS) {
    // Reset regex state
    pattern.lastIndex = 0;

    let match;
    while ((match = pattern.exec(code)) !== null) {
      const keyName = match[1];

      // Calculate line number
      const position = match.index;
      const lineNumber = code.substring(0, position).split('\n').length;

      // Avoid duplicates
      const isDuplicate = keys.some(
        (key) => key.keyName === keyName && key.line === lineNumber
      );

      if (!isDuplicate) {
        keys.push({
          keyName,
          line: lineNumber,
        });
      }
    }
  }

  return { keys };
}

module.exports = extract;
