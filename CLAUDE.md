# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Translation Guidelines

Translations are managed via Tolgee. Only write translations for `en-GB` locale.

**Important:** All user-facing strings must use translation functions. Never hardcode text strings directly in templates or components.

### Supported Patterns

**Vue/JS** (`resources/js/**/*.{js,vue}`):
- `$t('key.path')` - template/composition API
- `$tc('key.path')` / `tc('key.path')` - pluralization
- `<i18n-t keypath="key.path">` - interpolation component

In composables, `$t` is not available by default. Import it:
```js
const { t: $t } = useI18n()
```

**PHP** (`./src/**/*.php`):
- `__('mixpost::key.path')`

### Key Naming

Use dot notation with lowercase snake_case: `post_activity.scheduled_post`

### File Locations

- JSON: `resources/lang-json/`
- PHP: `resources/lang/`