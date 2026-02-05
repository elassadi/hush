# Locale Translation Script

This script scans German locale files and automatically generates English translations for missing keys.

## Usage

### As a Rake Task

```bash
# Run the translation task
rake locales:translate

# Or with Rails environment
rails locales:translate
```

### As a Standalone Script

```bash
# Dry run (preview changes without modifying files)
ruby scripts/translate_locales.rb --dry-run

# Process all German locale files
ruby scripts/translate_locales.rb

# Process a specific file
ruby scripts/translate_locales.rb --file=de.yml

# Verbose output
ruby scripts/translate_locales.rb --verbose

# Combine options
ruby scripts/translate_locales.rb --dry-run --file=avo.de.yml --verbose
```

## Options

- `--dry-run`: Preview changes without modifying files
- `--file=FILE`: Process only a specific German locale file (e.g., `de.yml`, `avo.de.yml`)
- `--verbose`: Show detailed output including generated translations preview
- `-h, --help`: Show help message

## How It Works

1. **Scans German locale files**: By default, scans `de.yml`, `avo.de.yml`, and `de.basic.yml`
2. **Compares with English files**: Checks corresponding English files (`en.yml`, `avo.en.yml`, `en.basic.yml`)
3. **Finds missing keys**: Identifies keys that exist in German but not in English
4. **Generates translations**: Uses a dictionary of common translations and pattern matching
5. **Preserves references**: Keeps Rails i18n references (e.g., `:activerecord.models.account`)
6. **Merges translations**: Safely merges new translations with existing English content

## Translation Strategy

The script uses multiple strategies:

1. **Exact matches**: Common German words/phrases mapped to English
2. **Pattern matching**: Recognizes common German sentence patterns
3. **Word replacement**: Replaces known German words within longer strings
4. **Preservation**: Keeps Rails i18n references and special markers

## Example Output

```
Starting locale translation scan...
================================================================================
Mode: DRY RUN (no files will be modified)
================================================================================

Processing: de.yml
--------------------------------------------------------------------------------
Found 15 missing translation(s):
  - actions.accounts.login_as_action.message: "Möchten Sie sich als Benutzer einloggen?"
  - actions.calendar_entries.cancel_action.message: "Möchten Sie den Kalendereintrag wirklich stornieren?"
  ...

[DRY RUN] Would update en.yml with 15 new translation(s)
```

## Notes

- The script preserves existing English translations
- References (starting with `:`) are kept as-is
- Nested hash structures are maintained
- The script is safe to run multiple times (idempotent)

## Files Processed

- `config/locales/de.yml` → `config/locales/en.yml`
- `config/locales/avo.de.yml` → `config/locales/avo.en.yml`
- `config/locales/de.basic.yml` → `config/locales/en.basic.yml`

## Manual Review Recommended

While the script provides automatic translations, manual review is recommended for:
- Complex sentences
- Domain-specific terminology
- Context-dependent translations
- HTML content with embedded text
