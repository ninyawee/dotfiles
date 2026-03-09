---
name: media-gen
description: Generate and edit images, and generate videos using Google GenAI models. Use when user asks to "generate image with Gemini/Nano Banana", "edit an image", "modify a photo", "create video with Veo", "make an image using Imagen", or requests media generation/editing with specific models like gemini-3.1-flash-image-preview, gemini-2.5-flash-image, gemini-3-pro-image-preview, imagen, veo-3.1, or veo-3.0. Also trigger when user provides an image and asks to transform, restyle, remove background, add elements, or change style.
---

# Media Generation & Editing

Generate and edit images, and generate videos using Google GenAI SDK (`google-genai`).

## Model Selection

| Task | Model | Use Case |
|------|-------|----------|
| Image (fast) | `gemini-3.1-flash-image-preview` (Nano Banana 2) | Speed-optimized, high volume |
| Image (default) | `gemini-2.5-flash-image` (Nano Banana) | Good balance of speed & quality |
| Image (pro) | `gemini-3-pro-image-preview` (Nano Banana Pro) | Studio-quality 4K, precise text |
| Image | `imagen` (Imagen 4) | Negative prompts, up to 2K |
| Image edit | Any Gemini model above | Edit/transform existing images |
| Video | `veo-3.1-generate-preview` | Best quality, audio |
| Video | `veo-3.1-fast-generate-preview` | Faster generation |

**Auto-selection logic:**
- Image without special needs → `gemini-2.5-flash-image`
- Image needing speed/volume → `gemini-3.1-flash-image-preview`
- Image needing 4K or pro quality → `gemini-3-pro-image-preview`
- Image with negative prompt → `imagen`
- Image editing → same Gemini model as generation (default `gemini-2.5-flash-image`)
- Video → `veo-3.1-generate-preview`

## Environment

Requires `GEMINI_API_KEY` or `GOOGLE_API_KEY` environment variable.

```bash
fnox get gemini-api-key  # or set GEMINI_API_KEY
```

## Image Generation

```bash
scripts/gen_image.py "A sunset over mountains" output.png
scripts/gen_image.py "A cat portrait" cat.jpg --model gemini-3-pro-image-preview --aspect-ratio 9:16
scripts/gen_image.py "Product photo" product.png --model imagen --negative-prompt "blurry"
```

## Image Editing

Pass `--input` with an existing image to edit it. The prompt describes the desired change. Only Gemini models support editing (not Imagen).

```bash
scripts/gen_image.py "Remove the background" clean.png --input photo.jpg
scripts/gen_image.py "Make it look like a watercolor painting" styled.png --input original.png
scripts/gen_image.py "Add a party hat to the cat" result.png --input cat.jpg
scripts/gen_image.py "Change the sky to sunset colors" sunset.png --input landscape.jpg --model gemini-3-pro-image-preview
```

**Editing capabilities:**
- Add, remove, or modify elements in the image
- Style transfer (photo → anime, watercolor, oil painting, etc.)
- Background removal or replacement
- Object insertion with realistic lighting
- Color grading and mood changes
- Text overlay

**Parameters:**
- `--input`: Path to the input image to edit
- `--model`: Model choice (default: `gemini-2.5-flash-image`)
- `--aspect-ratio`: 1:1, 16:9, 9:16, 4:3 (default: 1:1)
- `--negative-prompt`: What to avoid (Imagen only, generation only)

## Video Generation

```bash
scripts/gen_video.py "A cat walking through grass" cat.mp4
scripts/gen_video.py "Timelapse of clouds" clouds.mp4 --model veo-3.1-fast-generate-preview
scripts/gen_video.py "Camera panning over city" city.mp4 --image reference.jpg
```

**Parameters:**
- `--model`: Model choice (default: `veo-3.1-generate-preview`)
- `--image`: Input image for image-to-video
- `--negative-prompt`: What to avoid
- `--poll-interval`: Seconds between status checks (default: 10)

Video generation is async - script polls until complete.
