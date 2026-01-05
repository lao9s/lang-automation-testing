/**
 * Custom Tolgee extractor for branch localization keys JSON file
 * Extracts keys from a JSON array of key names
 */

/**
 * @param {string} code - File content
 * @param {string} fileName - File name
 * @returns {{ keys: Array<{ keyName: string; line: number }> }}
 */
function extract(code, fileName) {
  const keys = [];

  if (!code || typeof code !== 'string') {
    return { keys };
  }

  try {
    const keyNames = JSON.parse(code);

    if (Array.isArray(keyNames)) {
      for (const keyName of keyNames) {
        if (typeof keyName === 'string') {
          keys.push({
            keyName,
            line: 1,
          });
        }
      }
    }
  } catch (error) {
    // Not valid JSON, return empty keys
  }

  return { keys };
}

module.exports = extract;
