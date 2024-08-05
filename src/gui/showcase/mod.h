/*******************************************************************************************
*
*   Showcase v1.0.0 - Tool Description
*
*   MODULE USAGE:
*       #define GUI_SHOWCASE_IMPLEMENTATION
*       #include "gui_showcase.h"
*
*       INIT: GuiShowcaseState state = InitGuiShowcase();
*       DRAW: GuiShowcase(&state);
*
*   LICENSE: Propietary License
*
*   Copyright (c) 2022 raylib technologies. All Rights Reserved.
*
*   Unauthorized copying of this file, via any medium is strictly prohibited
*   This project is proprietary and confidential unless the owner allows
*   usage in any other form by expresely written permission.
*
**********************************************************************************************/

#include "raylib.h"

// WARNING: raygui implementation is expected to be defined before including this header
#undef RAYGUI_IMPLEMENTATION
#include "raygui.h"

#include <string.h>     // Required for: strcpy()

#ifndef GUI_SHOWCASE_H
#define GUI_SHOWCASE_H

typedef struct {
    // Define anchors
    Vector2 anchor01;            // ANCHOR ID:1
    Vector2 anchor02;            // ANCHOR ID:2
    
    // Define controls variables
    bool WindowBox001Active;            // WindowBox: WindowBox001
    bool Button005Pressed;            // Button: Button005
    bool LabelButton006Pressed;            // LabelButton: LabelButton006
    bool Toggle007Active;            // Toggle: Toggle007
    bool CheckBoxEx008Checked;            // CheckBoxEx: CheckBoxEx008
    int ToggleGroup009Active;            // ToggleGroup: ToggleGroup009
    int ComboBox010Active;            // ComboBox: ComboBox010
    bool DropdownBox011EditMode;
    int DropdownBox011Active;            // DropdownBox: DropdownBox011
    bool TextBox012EditMode;
    char TextBox012Text[128];            // TextBox: TextBox012
    bool ValueBOx013EditMode;
    int ValueBOx013Value;            // ValueBOx: ValueBOx013
    bool Spinner014EditMode;
    int Spinner014Value;            // Spinner: Spinner014
    float Slider015Value;            // Slider: Slider015
    float SliderBar016Value;            // SliderBar: SliderBar016
    float ProgressBar017Value;            // ProgressBar: ProgressBar017
    Rectangle ScrollPanel019ScrollView;
    Vector2 ScrollPanel019ScrollOffset;
    Vector2 ScrollPanel019BoundsOffset;            // ScrollPanel: ScrollPanel019
    int ListView020ScrollIndex;
    int ListView020Active;            // ListView: ListView020
    Color ColorPicker021Value;            // ColorPicker: ColorPicker021

    // Define rectangles
    Rectangle layoutRecs[23];

    // Custom state variables (depend on development software)
    // NOTE: This variables should be added manually if required

} GuiShowcaseState;

#ifdef __cplusplus
extern "C" {            // Prevents name mangling of functions
#endif

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Declaration
//----------------------------------------------------------------------------------
GuiShowcaseState InitGuiShowcase(void);
void GuiShowcase(GuiShowcaseState *state);

#ifdef __cplusplus
}
#endif

#endif // GUI_SHOWCASE_H

/***********************************************************************************
*
*   GUI_SHOWCASE IMPLEMENTATION
*
************************************************************************************/
#if defined(GUI_SHOWCASE_IMPLEMENTATION)

#include "raygui.h"

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Internal Module Functions Definition
//----------------------------------------------------------------------------------
//...

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------
GuiShowcaseState InitGuiShowcase(void)
{
    GuiShowcaseState state = { 0 };

    // Init anchors
    state.anchor01 = (Vector2){ 24, 24 };            // ANCHOR ID:1
    state.anchor02 = (Vector2){ 216, 24 };            // ANCHOR ID:2
    
    // Initilize controls variables
    state.WindowBox001Active = true;            // WindowBox: WindowBox001
    state.Button005Pressed = false;            // Button: Button005
    state.LabelButton006Pressed = false;            // LabelButton: LabelButton006
    state.Toggle007Active = true;            // Toggle: Toggle007
    state.CheckBoxEx008Checked = false;            // CheckBoxEx: CheckBoxEx008
    state.ToggleGroup009Active = 0;            // ToggleGroup: ToggleGroup009
    state.ComboBox010Active = 0;            // ComboBox: ComboBox010
    state.DropdownBox011EditMode = false;
    state.DropdownBox011Active = 0;            // DropdownBox: DropdownBox011
    state.TextBox012EditMode = false;
    strcpy(state.TextBox012Text, "SAMPLE TEXT");            // TextBox: TextBox012
    state.ValueBOx013EditMode = false;
    state.ValueBOx013Value = 0;            // ValueBOx: ValueBOx013
    state.Spinner014EditMode = false;
    state.Spinner014Value = 0;            // Spinner: Spinner014
    state.Slider015Value = 0.0f;            // Slider: Slider015
    state.SliderBar016Value = 0.0f;            // SliderBar: SliderBar016
    state.ProgressBar017Value = 0.0f;            // ProgressBar: ProgressBar017
    state.ScrollPanel019ScrollView = (Rectangle){ 0, 0, 0, 0 };
    state.ScrollPanel019ScrollOffset = (Vector2){ 0, 0 };
    state.ScrollPanel019BoundsOffset = (Vector2){ 0, 0 };            // ScrollPanel: ScrollPanel019
    state.ListView020ScrollIndex = 0;
    state.ListView020Active = 0;            // ListView: ListView020
    state.ColorPicker021Value = (Color){ 0, 0, 0, 0 };            // ColorPicker: ColorPicker021

    // Init controls rectangles
    state.layoutRecs[0] = (Rectangle){ state.anchor01.x + 0, state.anchor01.y + 0, 168, 384 };// GroupBox: GroupBox000
    state.layoutRecs[1] = (Rectangle){ state.anchor02.x + 0, state.anchor02.y + 0, 312, 384 };// WindowBox: WindowBox001
    state.layoutRecs[2] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 16, 120, 16 };// Line: Line002
    state.layoutRecs[3] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 48, 120, 36 };// Panel: Panel003
    state.layoutRecs[4] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 96, 120, 24 };// Label: Label004
    state.layoutRecs[5] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 144, 120, 24 };// Button: Button005
    state.layoutRecs[6] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 192, 120, 24 };// LabelButton: LabelButton006
    state.layoutRecs[7] = (Rectangle){ state.anchor01.x + 56, state.anchor01.y + 240, 88, 24 };// Toggle: Toggle007
    state.layoutRecs[8] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 240, 24, 24 };// CheckBoxEx: CheckBoxEx008
    state.layoutRecs[9] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 288, 40, 24 };// ToggleGroup: ToggleGroup009
    state.layoutRecs[10] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 336, 120, 24 };// ComboBox: ComboBox010
    state.layoutRecs[11] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 48, 120, 24 };// DropdownBox: DropdownBox011
    state.layoutRecs[12] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 96, 120, 24 };// TextBox: TextBox012
    state.layoutRecs[13] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 144, 120, 24 };// ValueBOx: ValueBOx013
    state.layoutRecs[14] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 192, 120, 24 };// Spinner: Spinner014
    state.layoutRecs[15] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 240, 120, 16 };// Slider: Slider015
    state.layoutRecs[16] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 264, 120, 16 };// SliderBar: SliderBar016
    state.layoutRecs[17] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 288, 120, 16 };// ProgressBar: ProgressBar017
    state.layoutRecs[18] = (Rectangle){ state.anchor02.x + 24, state.anchor02.y + 336, 120, 24 };// StatusBar: StatusBar018
    state.layoutRecs[19] = (Rectangle){ state.anchor02.x + 168, state.anchor02.y + 48, 120, 72 };// ScrollPanel: ScrollPanel019
    state.layoutRecs[20] = (Rectangle){ state.anchor02.x + 168, state.anchor02.y + 144, 120, 72 };// ListView: ListView020
    state.layoutRecs[21] = (Rectangle){ state.anchor02.x + 168, state.anchor02.y + 240, 96, 96 };// ColorPicker: ColorPicker021
    state.layoutRecs[22] = (Rectangle){ state.anchor02.x + 168, state.anchor02.y + 344, 120, 24 };// DummyRec: DummyRec022

    // Custom variables initialization

    return state;
}

void GuiShowcase(GuiShowcaseState *state)
{
    // Draw controls
    if (state->DropdownBox011EditMode) GuiLock();

    if (state->WindowBox001Active)
    {
        state->WindowBox001Active = !GuiWindowBox(state->layoutRecs[1], "SAMPLE TEXT");
        if (GuiTextBox(state->layoutRecs[12], state->TextBox012Text, 128, state->TextBox012EditMode)) state->TextBox012EditMode = !state->TextBox012EditMode;
        if (GuiValueBox(state->layoutRecs[13], "SAMPLE TEXT", &state->ValueBOx013Value, 0, 100, state->ValueBOx013EditMode)) state->ValueBOx013EditMode = !state->ValueBOx013EditMode;
        if (GuiSpinner(state->layoutRecs[14], "SAMPLE TEXT", &state->Spinner014Value, 0, 100, state->Spinner014EditMode)) state->Spinner014EditMode = !state->Spinner014EditMode;
        GuiSlider(state->layoutRecs[15], NULL, NULL, &state->Slider015Value, 0, 100);
        GuiSliderBar(state->layoutRecs[16], NULL, NULL, &state->SliderBar016Value, 0, 100);
        GuiProgressBar(state->layoutRecs[17], NULL, NULL, &state->ProgressBar017Value, 0, 1);
        GuiStatusBar(state->layoutRecs[18], "SAMPLE TEXT");
        GuiScrollPanel((Rectangle){state->layoutRecs[19].x, state->layoutRecs[19].y, state->layoutRecs[19].width - state->ScrollPanel019BoundsOffset.x, state->layoutRecs[19].height - state->ScrollPanel019BoundsOffset.y }, NULL, state->layoutRecs[19], &state->ScrollPanel019ScrollOffset, &state->ScrollPanel019ScrollView);
        GuiListView(state->layoutRecs[20], "ONE;TWO;THREE", &state->ListView020ScrollIndex, &state->ListView020Active);
        GuiColorPicker(state->layoutRecs[21], NULL, &state->ColorPicker021Value);
        GuiDummyRec(state->layoutRecs[22], "SAMPLE TEXT");
        if (GuiDropdownBox(state->layoutRecs[11], "ONE;TWO;THREE", &state->DropdownBox011Active, state->DropdownBox011EditMode)) state->DropdownBox011EditMode = !state->DropdownBox011EditMode;
    }
    GuiGroupBox(state->layoutRecs[0], "SAMPLE TEXT");
    GuiLine(state->layoutRecs[2], NULL);
    GuiPanel(state->layoutRecs[3], NULL);
    GuiLabel(state->layoutRecs[4], "SAMPLE TEXT");
    state->Button005Pressed = GuiButton(state->layoutRecs[5], "SAMPLE TEXT"); 
    state->LabelButton006Pressed = GuiLabelButton(state->layoutRecs[6], "SAMPLE TEXT");
    GuiToggle(state->layoutRecs[7], "SAMPLE TEXT", &state->Toggle007Active);
    GuiCheckBox(state->layoutRecs[8], "SAMPLE TEXT", &state->CheckBoxEx008Checked);
    GuiToggleGroup(state->layoutRecs[9], "ONE;TWO;THREE", &state->ToggleGroup009Active);
    GuiComboBox(state->layoutRecs[10], "ONE;TWO;THREE", &state->ComboBox010Active);
    
    GuiUnlock();
}

#endif // GUI_SHOWCASE_IMPLEMENTATION
