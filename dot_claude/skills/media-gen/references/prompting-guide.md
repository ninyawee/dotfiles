# Image Generation Prompting Guide

Best practices for prompting Gemini / Nano Banana image generation models.

## Core Principle

Describe the scene as a narrative paragraph, not a keyword list. The model understands intent, physics, and composition -- treat it like briefing a professional photographer or creative director.

## Prompt Structure

Combine these five components:

1. **Style** -- medium and aesthetic (photograph, watercolor, illustration, 3D render)
2. **Subject** -- who/what, appearance, clothing, pose, physical details
3. **Setting** -- location, environment, time of day, weather
4. **Action** -- what is happening in the scene
5. **Composition** -- framing, camera angle, aspect ratio

### Template by Use Case

**Photorealistic:**
> Shot type + Subject + Action + Environment + Lighting + Mood + Camera specs + Key details

**Product photography:**
> Resolution level + Product description + Surface/background + Lighting setup + Camera angle + Focus points

**Stylized illustration:**
> Style type + Subject + Characteristics + Color palette + Line style + Shading + Background

**Text-heavy (posters, diagrams):**
> Image type + Brand/concept + Exact text in quotes + Font style + Design approach + Color scheme

**Minimalist:**
> Single subject + Precise positioning + Empty background color + Lighting direction + Breathing room

## Photography Terms That Work

### Camera & Framing
close-up, wide-angle shot, macro shot, low-angle perspective, bird's eye view, over-the-shoulder, Dutch angle, 85mm portrait lens, medium telephoto, rule-of-thirds

### Lighting
soft diffused light, golden hour backlight, three-point softbox setup, dramatic side lighting, harsh shadows, rim light, neon reflection, studio lighting, high-contrast, sun-etched

### Focus & Quality
shallow depth of field, bokeh, sharp focus, ultra-realistic, high resolution, detailed textures, professional photography, 4K

## Style Keywords

### Art Styles
watercolor, oil painting, impasto brushstrokes, cel-shading, flat design, line art, gritty noir, Art Nouveau, Art Deco, ukiyo-e, pixel art, vaporwave, isometric, low-poly

### Mood & Atmosphere
cinematic, ethereal, moody, vibrant, muted earth tones, monochromatic, warm sunset colors, cool blue palette, high-key, low-key

### Surface & Material
etched patterns, intricate textures, ornate details, brushed metal, frosted glass, weathered wood, polished marble

## Do's

- **Be hyper-specific:** "ornate elven plate armor, etched with silver leaf patterns" not "fantasy armor"
- **Provide purpose context:** "logo for high-end skincare brand" helps the model understand intent
- **Use positive framing:** "empty deserted street" not "no cars"
- **Iterate with edits:** if 80% correct, ask for the specific change rather than regenerating
- **Specify exact text in quotes:** the model renders text well when given precise strings
- **Include physical descriptions:** "navy blue tweed suit jacket" not "suit jacket"
- **Describe lighting like a photographer:** specify direction, quality, and color temperature
- **Upload reference images** for style transfer, character consistency, or aspect ratio control

## Don'ts

- Don't use keyword soup -- write descriptive sentences
- Don't use negative framing for exclusions -- describe what you want instead
- Don't regenerate from scratch when a small edit would fix it
- Don't assume character consistency across separate prompts -- re-describe key details each time
- Don't skip aspect ratio specification when it matters

## Editing Prompts

### Inpainting (targeted edits)
> "Change only the [element] to [description]. Keep everything else unchanged."

### Style Transfer
> "Transform this into [art style]. Preserve composition but render with [specific stylistic elements]."

### Multi-Image Compositing
> "Take [element from image 1] and place it into [scene from image 2]."

## Example Prompts

**Product photo:**
> A professional product photograph of a white ceramic coffee mug sitting on a polished Carrara marble countertop. Studio lighting setup with a large softbox as the key light from the upper left, a fill light from the right, and a subtle rim light from behind. Shallow depth of field with the mug in sharp focus. Commercial product photography quality. Shot with a medium telephoto lens. No text, no logos.

**Character illustration:**
> A stoic robot barista with glowing blue optics and brushed titanium plating, standing behind a wooden espresso bar in a cozy steampunk cafe. Warm amber lighting from vintage Edison bulbs. Cel-shaded illustration style with bold outlines and muted earth tones.

**Logo:**
> A minimalist logo of a paper crane in flat design style on a pure white background. Clean geometric shapes, single color (deep teal), centered composition with generous negative space. Vector-style illustration.
