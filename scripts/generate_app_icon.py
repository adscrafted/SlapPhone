#!/usr/bin/env python3
"""
SlapPhone App Icon Generator

Generates the app icon using AI and exports all required sizes.

Requirements:
- Google AI API key
- ImageMagick for resizing (brew install imagemagick)

Usage:
    python3 generate_app_icon.py --api-key YOUR_KEY

    # Or with environment variable:
    GOOGLE_AI_API_KEY=your_key python3 generate_app_icon.py
"""

import argparse
import base64
import json
import os
import subprocess
import sys
import urllib.request
from pathlib import Path

# Output locations
PROJECT_DIR = Path(__file__).parent.parent
ASSETS_DIR = PROJECT_DIR / "SlapPhone" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset"
OUTPUT_DIR = PROJECT_DIR / "AppIcon"

# iOS App Icon sizes (iOS 12+, single 1024x1024 is used)
ICON_SIZES = [
    (1024, 1024, "AppIcon.png"),  # App Store
]

# Legacy sizes if needed
LEGACY_SIZES = [
    (180, 180, "Icon-180.png"),   # iPhone @3x
    (120, 120, "Icon-120.png"),   # iPhone @2x
    (167, 167, "Icon-167.png"),   # iPad Pro @2x
    (152, 152, "Icon-152.png"),   # iPad @2x
    (76, 76, "Icon-76.png"),      # iPad @1x
]

# Colors from the app
COLORS = {
    "primary": "#FF6B5B",      # Coral/Orange
    "secondary": "#FFD93D",    # Yellow
    "background": "#1C1C1E",   # Dark charcoal
    "text": "#FFFFFF",         # White
}

# The master prompt for generating the icon
ICON_PROMPT = """A bold modern iOS app icon design for SlapPhone.

SUBJECT: A stylized smartphone with a surprised, cartoonish expression being struck by an open palm hand. The phone has simple dot eyes and an "O" shaped mouth showing shock and surprise.

COMPOSITION: The hand enters from the upper-left, palm open in a slapping motion. The phone is centered-right, tilting from the impact. Impact/shock lines radiate outward from the point of contact in a dynamic starburst pattern.

STYLE: Clean vector-style flat illustration with minimal gradients. Bold graphic shapes with playful energy. Comic book impact aesthetic.

COLORS:
- Hand and impact lines: coral-orange (#FF6B5B)
- Phone body: white or light gray
- Phone face/expression: black eyes, coral mouth
- Background: rich dark charcoal (#1C1C1E)

IMPORTANT CONSTRAINTS:
- NO text anywhere on the icon
- Square 1:1 aspect ratio
- High contrast for visibility at small sizes
- Clean edges suitable for iOS rounded corner masking
- Apple App Store icon design language
- Instantly readable at 60x60 pixels
"""


def generate_icon_with_ai(api_key: str) -> bytes | None:
    """Generate the app icon using Gemini."""
    print("🎨 Generating app icon with AI...")

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent?key={api_key}"

    body = {
        "contents": [{"parts": [{"text": ICON_PROMPT}]}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {
                "aspectRatio": "1:1",
                "imageSize": "2K"  # Generate at 2K for quality, resize down
            }
        }
    }

    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(body).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST"
        )

        with urllib.request.urlopen(req, timeout=120) as resp:
            result = json.loads(resp.read().decode("utf-8"))

        # Extract image from response
        if "candidates" in result and result["candidates"]:
            parts = result["candidates"][0].get("content", {}).get("parts", [])
            for part in parts:
                if "inlineData" in part:
                    print("✅ Icon generated successfully!")
                    return base64.b64decode(part["inlineData"]["data"])

        # Check for safety block
        if "candidates" in result:
            finish_reason = result["candidates"][0].get("finishReason", "")
            if finish_reason == "IMAGE_SAFETY":
                print("⚠️ Safety filter triggered. Trying with modified prompt...")
                return generate_icon_with_simplified_prompt(api_key)

        print(f"❌ No image in API response")
        print(f"   Response: {json.dumps(result, indent=2)[:500]}")
        return None

    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8") if e.fp else "No details"
        print(f"❌ API error: {e.code}")
        print(f"   {error_body[:300]}")
        return None
    except Exception as e:
        print(f"❌ Error: {e}")
        return None


def generate_icon_with_simplified_prompt(api_key: str) -> bytes | None:
    """Try with a simpler prompt if the first one gets blocked."""
    print("🎨 Trying simplified prompt...")

    simple_prompt = """A modern app icon with a playful cartoon smartphone showing a surprised expression.
The phone has simple dot eyes and round mouth. Orange (#FF6B5B) starburst lines radiate behind it
suggesting impact or excitement. Dark charcoal (#1C1C1E) background. Clean flat vector style.
No text. Square format. Apple App Store icon aesthetic."""

    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent?key={api_key}"

    body = {
        "contents": [{"parts": [{"text": simple_prompt}]}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {
                "aspectRatio": "1:1",
                "imageSize": "2K"
            }
        }
    }

    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(body).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST"
        )

        with urllib.request.urlopen(req, timeout=120) as resp:
            result = json.loads(resp.read().decode("utf-8"))

        if "candidates" in result and result["candidates"]:
            parts = result["candidates"][0].get("content", {}).get("parts", [])
            for part in parts:
                if "inlineData" in part:
                    print("✅ Icon generated with simplified prompt!")
                    return base64.b64decode(part["inlineData"]["data"])

        return None
    except Exception as e:
        print(f"❌ Simplified prompt also failed: {e}")
        return None


def resize_icon(source: Path, width: int, height: int, output: Path) -> bool:
    """Resize icon using ImageMagick."""
    try:
        cmd = [
            "magick",
            str(source),
            "-resize", f"{width}x{height}",
            "-quality", "100",
            str(output)
        ]
        subprocess.run(cmd, check=True, capture_output=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        # Try with 'convert' (ImageMagick 6)
        try:
            cmd = [
                "convert",
                str(source),
                "-resize", f"{width}x{height}",
                "-quality", "100",
                str(output)
            ]
            subprocess.run(cmd, check=True, capture_output=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False


def update_contents_json():
    """Update the Contents.json to reference the icon file."""
    contents = {
        "images": [
            {
                "filename": "AppIcon.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }

    contents_path = ASSETS_DIR / "Contents.json"
    with open(contents_path, "w") as f:
        json.dump(contents, f, indent=2)
    print(f"✅ Updated {contents_path}")


def main():
    parser = argparse.ArgumentParser(description="Generate SlapPhone app icon")
    parser.add_argument(
        "--api-key",
        default=os.environ.get("GOOGLE_AI_API_KEY"),
        help="Google AI API key"
    )
    parser.add_argument(
        "--export-sizes",
        action="store_true",
        help="Also export legacy icon sizes"
    )

    args = parser.parse_args()

    if not args.api_key:
        print("❌ No API key provided.")
        print("   Set GOOGLE_AI_API_KEY environment variable or use --api-key")
        print("")
        print("   Get a free key at: https://aistudio.google.com/apikey")
        sys.exit(1)

    print("=" * 50)
    print("SlapPhone App Icon Generator")
    print("=" * 50)

    # Generate the icon
    icon_data = generate_icon_with_ai(args.api_key)

    if not icon_data:
        print("\n❌ Failed to generate icon")
        sys.exit(1)

    # Save to assets directory
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Save main icon
    main_icon_path = ASSETS_DIR / "AppIcon.png"
    with open(main_icon_path, "wb") as f:
        f.write(icon_data)
    print(f"✅ Saved: {main_icon_path}")

    # Also save to output directory
    output_icon_path = OUTPUT_DIR / "AppIcon-1024.png"
    with open(output_icon_path, "wb") as f:
        f.write(icon_data)
    print(f"✅ Saved: {output_icon_path}")

    # Update Contents.json
    update_contents_json()

    # Export other sizes if requested
    if args.export_sizes:
        print("\n📐 Exporting additional sizes...")
        for width, height, name in LEGACY_SIZES:
            output_path = OUTPUT_DIR / name
            if resize_icon(main_icon_path, width, height, output_path):
                print(f"  ✅ {name} ({width}x{height})")
            else:
                print(f"  ❌ Failed to create {name}")

    print("\n" + "=" * 50)
    print("✅ App icon generation complete!")
    print(f"   Icon saved to: {main_icon_path}")
    print("=" * 50)


if __name__ == "__main__":
    main()
