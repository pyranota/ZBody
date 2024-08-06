/*******************************************************************************************
*
*   Settings v1.0.0 - Tool Description
*
*   MODULE USAGE:
*       #define GUI_SETTINGS_IMPLEMENTATION
*       #include "gui_settings.h"
*
*       INIT: GuiSettingsState state = InitGuiSettings();
*       DRAW: GuiSettings(&state);
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

#ifndef GUI_SETTINGS_H
#define GUI_SETTINGS_H

typedef struct {
    // Define anchors
    Vector2 anchor01;            // ANCHOR ID:1
    
    // Define controls variables
    bool WindowBox002Active;            // WindowBox: WindowBox002
    int ComboBox001Active;            // ComboBox: ComboBox001
    bool CheckBoxEx005Checked;            // CheckBoxEx: CheckBoxEx005

    // Define rectangles
    Rectangle layoutRecs[6];

    // Custom state variables (depend on development software)
    // NOTE: This variables should be added manually if required

} GuiSettingsState;

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
GuiSettingsState InitGuiSettings(void);
void GuiSettings(GuiSettingsState *state);

#ifdef __cplusplus
}
#endif

#endif // GUI_SETTINGS_H

/***********************************************************************************
*
*   GUI_SETTINGS IMPLEMENTATION
*
************************************************************************************/
#if defined(GUI_SETTINGS_IMPLEMENTATION)

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
GuiSettingsState InitGuiSettings(void)
{
    GuiSettingsState state = { 0 };

    // Init anchors
    state.anchor01 = (Vector2){ 424, 296 };            // ANCHOR ID:1
    
    // Initilize controls variables
    state.WindowBox002Active = true;            // WindowBox: WindowBox002
    state.ComboBox001Active = 0;            // ComboBox: ComboBox001
    state.CheckBoxEx005Checked = false;            // CheckBoxEx: CheckBoxEx005

    // Init controls rectangles
    state.layoutRecs[0] = (Rectangle){ state.anchor01.x + 0, state.anchor01.y + 0, 240, 192 };// WindowBox: WindowBox002
    state.layoutRecs[1] = (Rectangle){ state.anchor01.x + 88, state.anchor01.y + 96, 120, 24 };// ComboBox: ComboBox001
    state.layoutRecs[2] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 48, 120, 24 };// Label: Label002
    state.layoutRecs[3] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 72, 192, 12 };// Line: Line003
    state.layoutRecs[4] = (Rectangle){ state.anchor01.x + 32, state.anchor01.y + 96, 48, 24 };// Label: Label004
    state.layoutRecs[5] = (Rectangle){ state.anchor01.x + 24, state.anchor01.y + 144, 24, 24 };// CheckBoxEx: CheckBoxEx005

    // Custom variables initialization

    return state;
}

void GuiSettings(GuiSettingsState *state)
{
    // Draw controls
    if (state->WindowBox002Active)
    {
        state->WindowBox002Active = !GuiWindowBox(state->layoutRecs[0], "Settings");
        GuiComboBox(state->layoutRecs[1], "ONE;TWO;THREE", &state->ComboBox001Active);
        GuiLabel(state->layoutRecs[2], "Appereance");
        GuiLine(state->layoutRecs[3], NULL);
        GuiLabel(state->layoutRecs[4], "Style:");
        GuiCheckBox(state->layoutRecs[5], "Fullscreen", &state->CheckBoxEx005Checked);
    }
}

#endif // GUI_SETTINGS_IMPLEMENTATION
