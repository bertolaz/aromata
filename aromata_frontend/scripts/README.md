# Icon Management Scripts

## copy_web_icons.sh

This script copies icons from `assets/icons` to `web/icons` for PWA support.

### Usage

```bash
cd aromata_frontend
bash scripts/copy_web_icons.sh
```

### What it does

- Copies `ios_1024.png` → `web/icons/Icon-512.png` (for PWA 512x512 icon)
- Copies `ios_60.png` → `web/icons/Icon-192.png` (for PWA 192x192 icon)
- Creates maskable versions for better PWA support

### When to run

Run this script whenever you update icons in `assets/icons/` to ensure the web PWA uses the latest icons.

### Note

The script uses the iOS icons as the source. If you need different sizes, you may want to resize the icons manually or use image editing tools to create properly sized versions.

