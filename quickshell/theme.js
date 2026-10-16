// "Golden hour", picked from hypr/bg.jpg: a misty valley at sunset.
// Smoky olive-black glass, the gold of the mist as the accent, cream text.

const font = {
  family: "Iosevka Nerd Font",
  size: 16,
  sizeSmall: 14,
  weight: 600,
  weightBold: 800,
}

const colors = {
  // Island and pills: translucent, Hyprland blurs what's behind (layer rule "island")
  bg: "#D9171510",
  // Rows, buttons, slider tracks on top of bg
  surface: "#2C271E",
  surfaceHover: "#3A3327",
  // Hairline edge of the glass, dividers
  line: "#2EF3DDB0",
  shadow: "#66000000",

  accent: "#E2B064",
  // Text/icons on the accent
  onAccent: "#1B160E",

  text: "#EEE3CD",
  textBright: "#FFF8EA",
  textDim: "#968A73",

  danger: "#D9714E",
}

// Corners: small things / opened panels (closed pills are fully round)
const radius = 12
const radiusLarge = 26

const margin = 20
// Inside opened panels
const padding = 20
// Vertical padding of the top row (text height + rowPadding)
const rowPadding = 16

// Morphs and slides / fades of contents. No overshoot anywhere: Easing.OutQuint
const duration = 260
const durationFast = 160
