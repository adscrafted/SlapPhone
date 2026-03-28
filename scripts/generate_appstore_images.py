#!/usr/bin/env python3
"""
SlapPhone App Store Screenshot Generator

Workflow:
1. Capture raw screenshots via Fastlane snapshot
2. Process each screenshot with AI to add marketing frames/text
3. Output final App Store ready images

Requirements:
- Fastlane installed (gem install fastlane)
- Google AI API key for image generation
- ImageMagick for compositing (brew install imagemagick)

Usage:
    python3 generate_appstore_images.py [--api-key KEY] [--skip-capture]
"""

import argparse
import base64
import json
import os
import subprocess
import sys
import urllib.request
from datetime import datetime
from pathlib import Path

# Configuration
SCREENSHOTS_DIR = Path("fastlane/screenshots")
OUTPUT_DIR = Path("fastlane/appstore_images")
REFERENCE_DIR = Path("fastlane/screenshot_references")

# Device sizes for App Store
DEVICE_SIZES = {
    "iPhone 16 Pro Max": {"width": 1290, "height": 2796, "display": "6.7"},
    "iPhone 15 Plus": {"width": 1284, "height": 2778, "display": "6.7"},
    "iPhone 8 Plus": {"width": 1242, "height": 2208, "display": "5.5"},
    "iPad Pro 12.9": {"width": 2048, "height": 2732, "display": "12.9"},
}

# Marketing copy for each screenshot
SCREENSHOT_CONFIG = [
    {
        "name": "1_splash",
        "headline": "IT SCREAMS BACK",
        "subheadline": "Your phone has feelings now",
        "prompt_style": "dramatic impact effect, phone being slapped with shock waves"
    },
    {
        "name": "2_home",
        "headline": "SLAP IT",
        "subheadline": "Detects every impact",
        "prompt_style": "clean UI showcase, subtle glow effect around impact visualizer"
    },
    {
        "name": "3_voicepacks",
        "headline": "4 VOICE PACKS",
        "subheadline": "From screams to squeaks",
        "prompt_style": "playful grid showcase with sound wave decorations"
    },
    {
        "name": "4_settings",
        "headline": "CUSTOMIZE",
        "subheadline": "Adjust sensitivity your way",
        "prompt_style": "clean settings interface with slider highlight"
    },
    {
        "name": "5_stats",
        "headline": "TRACK IT ALL",
        "subheadline": "Lifetime slaps counted",
        "prompt_style": "stats showcase with number animations"
    },
    {
        "name": "6_impact",
        "headline": "FEEL THE HIT",
        "subheadline": "Haptic feedback included",
        "prompt_style": "flash effect, impact moment capture"
    },
]

# Colors
COLORS = {
    "primary": "#FF6B5B",      # Coral/Orange
    "secondary": "#FFD93D",    # Yellow
    "background": "#1C1C1E",   # Dark
    "text": "#FFFFFF",         # White
    "muted": "#8E8E93",        # Gray
}


def run_fastlane_screenshots():
    """Capture screenshots using Fastlane snapshot."""
    print("📸 Capturing screenshots with Fastlane...")
    try:
        subprocess.run(
            ["fastlane", "screenshots"],
            cwd=Path.cwd(),
            check=True
        )
        print("✅ Screenshots captured successfully")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Fastlane failed: {e}")
        return False
    except FileNotFoundError:
        print("❌ Fastlane not found. Install with: gem install fastlane")
        return False


def load_screenshot(path: Path) -> bytes:
    """Load a screenshot and return as bytes."""
    with open(path, "rb") as f:
        return f.read()


def save_image(data: bytes, path: Path):
    """Save image bytes to file."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "wb") as f:
        f.write(data)
    print(f"  💾 Saved: {path}")


def generate_marketing_frame(
    screenshot_path: Path,
    config: dict,
    device: str,
    api_key: str
) -> bytes | None:
    """
    Generate an App Store marketing frame using AI.

    Takes a raw screenshot and creates a marketing-style image
    with text overlays and stylized backgrounds.
    """
    # Read the screenshot
    screenshot_data = load_screenshot(screenshot_path)
    screenshot_b64 = base64.b64encode(screenshot_data).decode("utf-8")

    device_info = DEVICE_SIZES.get(device, DEVICE_SIZES["iPhone 16 Pro Max"])

    # Construct the AI prompt for App Store image
    prompt = f"""Create an App Store marketing screenshot for SlapPhone app.

TASK: Take this iPhone screenshot and create a polished App Store marketing image.

REQUIREMENTS:
- Keep the screenshot CENTERED and at full resolution
- Add a subtle gradient background in dark charcoal ({COLORS['background']}) to coral ({COLORS['primary']})
- Add the headline "{config['headline']}" at the TOP in bold white SF Pro Display font
- Add the subheadline "{config['subheadline']}" below the headline in muted gray
- Optional: Add subtle decorative elements matching the theme: {config['prompt_style']}
- DO NOT obscure the app screenshot - it should be the hero element
- Final dimensions: {device_info['width']} x {device_info['height']} pixels
- Clean, minimal, Apple App Store marketing style
- Professional typography with proper spacing

The screenshot shows the app's {config['name'].replace('_', ' ')} screen.
Make this look like a premium App Store listing image that converts browsers to buyers.
"""

    # Call Gemini API with image input
    url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-image-preview:generateContent?key={api_key}"

    body = {
        "contents": [{
            "parts": [
                {"text": prompt},
                {
                    "inlineData": {
                        "mimeType": "image/png",
                        "data": screenshot_b64
                    }
                }
            ]
        }],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {
                "aspectRatio": "9:16",  # Portrait for App Store
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

        # Extract image from response
        if "candidates" in result and result["candidates"]:
            parts = result["candidates"][0].get("content", {}).get("parts", [])
            for part in parts:
                if "inlineData" in part:
                    return base64.b64decode(part["inlineData"]["data"])

        print(f"  ⚠️ No image in API response for {config['name']}")
        return None

    except Exception as e:
        print(f"  ❌ API error for {config['name']}: {e}")
        return None


def create_simple_frame_with_imagemagick(
    screenshot_path: Path,
    config: dict,
    device: str,
    output_path: Path
):
    """
    Create a simple marketing frame using ImageMagick.
    Fallback when AI generation is unavailable.
    """
    device_info = DEVICE_SIZES.get(device, DEVICE_SIZES["iPhone 16 Pro Max"])

    # Create background with gradient
    bg_cmd = [
        "magick",
        "-size", f"{device_info['width']}x{device_info['height']}",
        f"gradient:{COLORS['background']}-{COLORS['primary']}",
        "-rotate", "90",
        "/tmp/slapphone_bg.png"
    ]

    # Composite screenshot onto background
    composite_cmd = [
        "magick",
        "/tmp/slapphone_bg.png",
        str(screenshot_path),
        "-gravity", "center",
        "-geometry", f"+0+100",  # Offset down for text
        "-composite",
        str(output_path)
    ]

    # Add text (headline)
    text_cmd = [
        "magick",
        str(output_path),
        "-gravity", "north",
        "-pointsize", "72",
        "-fill", COLORS["text"],
        "-font", "SF-Pro-Display-Bold",
        "-annotate", "+0+100", config["headline"],
        str(output_path)
    ]

    try:
        subprocess.run(bg_cmd, check=True, capture_output=True)
        subprocess.run(composite_cmd, check=True, capture_output=True)
        subprocess.run(text_cmd, check=True, capture_output=True)
        print(f"  ✅ Created frame with ImageMagick: {output_path}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"  ❌ ImageMagick failed: {e}")
        return False
    except FileNotFoundError:
        print("  ⚠️ ImageMagick not found. Install with: brew install imagemagick")
        return False


def process_screenshots(api_key: str | None, skip_capture: bool = False):
    """Main processing pipeline."""

    # Step 1: Capture screenshots
    if not skip_capture:
        if not run_fastlane_screenshots():
            print("⚠️ Continuing with existing screenshots...")

    # Step 2: Find captured screenshots
    if not SCREENSHOTS_DIR.exists():
        print(f"❌ Screenshots directory not found: {SCREENSHOTS_DIR}")
        print("   Run 'fastlane screenshots' first or use --skip-capture with existing screenshots")
        return

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Step 3: Process each screenshot config
    for device in DEVICE_SIZES:
        device_dir = SCREENSHOTS_DIR / device.replace(" ", "_")
        if not device_dir.exists():
            continue

        print(f"\n📱 Processing {device}...")

        for config in SCREENSHOT_CONFIG:
            screenshot_name = f"{config['name']}.png"
            screenshot_path = device_dir / screenshot_name

            if not screenshot_path.exists():
                print(f"  ⏭️ Skipping {config['name']} - not found")
                continue

            print(f"  🎨 Processing {config['name']}...")

            output_path = OUTPUT_DIR / device.replace(" ", "_") / f"appstore_{config['name']}.png"
            output_path.parent.mkdir(parents=True, exist_ok=True)

            # Try AI generation first
            if api_key:
                result = generate_marketing_frame(
                    screenshot_path,
                    config,
                    device,
                    api_key
                )
                if result:
                    save_image(result, output_path)
                    continue

            # Fall back to ImageMagick
            create_simple_frame_with_imagemagick(
                screenshot_path,
                config,
                device,
                output_path
            )

    print(f"\n✅ Done! App Store images saved to: {OUTPUT_DIR}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate App Store marketing screenshots for SlapPhone"
    )
    parser.add_argument(
        "--api-key",
        default=os.environ.get("GOOGLE_AI_API_KEY"),
        help="Google AI API key (or set GOOGLE_AI_API_KEY env var)"
    )
    parser.add_argument(
        "--skip-capture",
        action="store_true",
        help="Skip Fastlane capture, use existing screenshots"
    )

    args = parser.parse_args()

    print("=" * 50)
    print("SlapPhone App Store Screenshot Generator")
    print("=" * 50)

    if not args.api_key:
        print("⚠️ No API key provided. Will use ImageMagick fallback.")
        print("   For AI-enhanced images, set GOOGLE_AI_API_KEY or use --api-key")

    process_screenshots(args.api_key, args.skip_capture)


if __name__ == "__main__":
    main()
