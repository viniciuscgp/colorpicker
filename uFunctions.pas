unit uFunctions;

interface

uses Graphics, Windows;

type
  THSL = record
    Hue: Integer;
    Saturation: Integer;  //fade a color to gray
    Lightness: Integer;   //make a color darker
  end;

function ColorToHSLDegree(Color: TColor): THSL;
function ColorToHSLWindow(Color: TColor): THSL;
function HSLToColorDegree(HSL: THSL): TColor;
function HSLToColorWindow(HSL: THSL): TColor;

implementation

procedure MinMaxDouble3(const Value1, Value2, Value3: Real; var Min, Max: Real);
begin
  if Value1 > Value2 then
  begin
    if Value1 > Value3 then
      Max := Value1
    else
      Max := Value3;

    if Value2 < Value3 then
      Min := Value2
    else
      Min := Value3
  end
  else
  begin
    if Value2 > Value3 then
      Max := Value2
    else
      Max := Value3;

    if Value1 < Value3 then
      Min := Value1
    else
      Min := Value3
  end;
end;

// Returns the HSL value (in degrees) of an RGB color (0..255)
//   H = 0 to 360 (corresponding to 0..360 degrees around the hexcone)
//   S = 0% (shade of gray) to 100% (pure color)
//   L = 0% (black) to 100% (white)
function ColorToHSLDegree(Color: TColor): THSL;
var
  r, g, b, delta, min, max: Real;
  h, s, l: Real;
begin
  r := GetRValue(ColorToRGB(Color)) / 255;
  g := GetGValue(ColorToRGB(Color)) / 255;
  b := GetBValue(ColorToRGB(Color)) / 255;
  MinMaxDouble3(r, g, b, min, max);

  // Calculate luminosity
  l := (max + min) / 2;

  if max = min then   //it's gray
  begin
    h := 0  ;         //it's actually undefined
    s := 0;
  end
  else
  begin
    delta := max - min;

    // Calculate saturation
    if l < 0.5 then
      s := delta / (max + min)
    else
      s := delta / (2 - max - min);

    // Calculate hue
    if r = max then
      h := (g - b) / delta
    else
      if g = max then
        h := 2 + (b - r) / delta
      else
        h := 4 + (r - g) / delta;

    h := h / 6;
    if h < 0 then h := h + 1;
  end;

  Result.Hue        := Round(h * 360);
  Result.Saturation := Round(s * 100);
  Result.Lightness  := Round(l * 100);
end;

// Returns the HSL value of an RGB color (0..255)
//   H = 0 to 239 (corresponding to windows color dialog)
//   S = 0 (shade of gray) to 240 (pure color)
//   L = 0 (black) to 240 (white)
function ColorToHSLWindow(Color: TColor): THSL;
var
  r, g, b, delta, min, max: Real;
  h, s, l: Real;
begin
  r := GetRValue(ColorToRGB(Color)) / 255;
  g := GetGValue(ColorToRGB(Color)) / 255;
  b := GetBValue(ColorToRGB(Color)) / 255;
  MinMaxDouble3(r, g, b, min, max);

  // Calculate luminosity
  l := (max + min) / 2;

  if max = min then   //it's gray
  begin
    h := 0;           //it's actually undefined
    s := 0;
  end
  else
  begin
    delta := max - min;

    // Calculate saturation
    if l < 0.5 then
      s := delta / (max + min)
    else
      s := delta / (2 - max - min);

    // Calculate hue
    if r = max then
      h := (g - b) / delta
    else
      if g = max then
        h := 2 + (b - r) / delta
      else
        h := 4 + (r - g) / delta;

    h := h / 6;
    if h < 0 then h := h + 1;
  end;

  Result.Hue        := Round(h * 240);
  if Result.Hue = 240 then Result.Hue := 0;
  Result.Saturation := Round(s * 240);
  Result.Lightness  := Round(l * 240);
end;

// Returns the RGB color of an HSL degrees value
function HSLToColorDegree(HSL: THSL): TColor;
var
  m1, m2: Real;

  function HueToColorValue(Hue: Real): Byte;
  var
    v: Real;
  begin
    if Hue < 0 then
      Hue := Hue + 1
    else
      if Hue > 1 then Hue := Hue - 1;

    if 6 * Hue < 1 then
      v := m1 + (m2 - m1) * Hue * 6
    else
      if 2 * Hue < 1 then
        v := m2
      else
        if 3 * Hue < 2 then
          v := m1 + (m2 - m1) * (2/3 - Hue) * 6
        else
          v := m1;

    Result := Round(255 * v);
  end;

var
  h, s, l: Real;
  r, g, b: Byte;
begin
  h := HSL.Hue / 360;
  s := HSL.Saturation / 100;
  l := HSL.Lightness / 100;

  if s = 0 then
  begin
    r := Round(255 * L);
    g := r;
    b := r;
  end
  else
  begin
    if l <= 0.5 then
      m2 := l * (1 + s)
    else
      m2 := l + s - l * s;

    m1 := 2 * l - m2;

    r := HueToColorValue(h + 1/3);
    g := HueToColorValue(h);
    b := HueToColorValue(h - 1/3);
  end;

  Result := RGB(r, g, b);
end;

// Returns the RGB color of an HSL Windows value
function HSLToColorWindow(HSL: THSL): TColor;
var
  m1, m2: Real;

  function HueToColorValue(Hue: Real): Byte;
  var
    v: Real;
  begin
    if Hue < 0 then
      Hue := Hue + 1
    else
      if Hue > 1 then Hue := Hue - 1;

    if 6 * Hue < 1 then
      v := m1 + (m2 - m1) * Hue * 6
    else
      if 2 * Hue < 1 then
        v := m2
      else
        if 3 * Hue < 2 then
          v := m1 + (m2 - m1) * (2/3 - Hue) * 6
        else
          v := m1;

    Result := Round(255 * v);
  end;

var
  h, s, l: Real;
  r, g, b: Byte;
begin
  h := HSL.Hue / 240;
  s := HSL.Saturation / 240;
  l := HSL.Lightness / 240;

  if s = 0 then
  begin
    r := Round(255 * L);
    g := r;
    b := r;
  end
  else
  begin
    if l <= 0.5 then
      m2 := l * (1 + s)
    else
      m2 := l + s - l * s;

    m1 := 2 * l - m2;

    r := HueToColorValue(h + 1/3);
    g := HueToColorValue(h);
    b := HueToColorValue(h - 1/3);
  end;

  Result := RGB(r, g, b);
end;


end.
