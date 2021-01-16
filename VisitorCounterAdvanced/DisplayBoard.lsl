/*
BSD 3-Clause License
Copyright (c) 2020, Sara Payne
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
integer displayComsChannel = -6827416;
integer displayComsChannelListen;
list todaysVisitors =[];
integer debug = FALSE;

SetUpListeners()
{//sets the coms channel and the random menu channel then turns the listeners on.
    displayComsChannelListen = llListen(displayComsChannel, "", NULL_KEY, "");
    llListenControl (displayComsChannelListen, TRUE);    
}//close set up listeners

ApplyDynamicTexture(float rotationRAD, string text)
{   //sets the shape of the box and textures it rotating the arrow to the specified position
    string sDynamicID = "";                          // not implemented yet
    string sContentType = "vector";                  // vector = text/lines,etc.  image = texture only
    string sData = "";                               // Storage for our drawing commands
    string sExtraParams = "width:1024,height:512";    // optional parameters in the following format: [param]:[value],[param]:[value]
    integer iTimer = 0;                               // timer is not implemented yet, leave @ 0
    integer iAlpha = 100;                            // 0 = 100% Alpha, 255 = 100% Solid
    // draw a rectangle
    sData = osSetPenSize(sData, 3);                   // Set the pen width to 3 pixels
    sData = osSetPenColor(sData, "Black");             // Set the pen color to red
    sData = osMovePen(sData, 0, 0);                 // Upper left corner at <28,78>
    sData = osDrawFilledRectangle(sData, 1024, 512);   // 200 pixels by 100 pixels
    // setup text to go in the drawn box
    sData = osMovePen(sData, 30, 10);                 // place pen @ X,Y coordinates 
    sData = osSetFontName(sData, "Arial");            // Set the Fontname to use
    sData = osSetFontSize(sData, 20);                 // Set the Font Size in pixels
    sData = osSetPenColor(sData, "White");           // Set the pen color to Green
    sData = osDrawText(sData, text); // The text to write
    //do the draw multiple times so its actually black and not grey
    osSetDynamicTextureDataBlend( sDynamicID, sContentType, sData, sExtraParams, iTimer, iAlpha ); // Now draw it out
    osSetDynamicTextureDataBlend( sDynamicID, sContentType, sData, sExtraParams, iTimer, iAlpha ); // Now draw it out
    osSetDynamicTextureDataBlend( sDynamicID, sContentType, sData, sExtraParams, iTimer, iAlpha ); // Now draw it out
}//close apply shape texture

SetBaseImage()
{
    llSetLinkPrimitiveParamsFast(LINK_ROOT, [ PRIM_TEXTURE, ALL_SIDES, "802934bf-fcfb-4540-b7fa-b17585880d2b", <1,1,1>, <1,1,1>, 0 ]); //set the image
}

ProcessListenMessage(string message)
{
    if (debug)
    {
        llOwnerSay("Debug:ProcessListenMessage:Entered");
    }
    if (message == "Reset")
    {
        if(debug)
        {
            llOwnerSay("Debug:ProcessListenMessage:Reset");
        }
        llResetScript();
    }
    else
    {
        if (debug)
        {
            llOwnerSay("Debug:ProcessListenMessage:UUID:" + message);
        }
        UpdateDisplay(message);
    }
}

UpdateDisplay(string message)
{
    string name = llKey2Name((key)message);
    if(!(~llListFindList(todaysVisitors, (list)name)))
    {
        todaysVisitors += name;
        UpdateDisplayText();
    }
}

UpdateDisplayText()
{
    string displayString = GenDisplayString();
    SetBaseImage();
    ApplyDynamicTexture(0, displayString);
}

string GenDisplayString ()
{
    if (debug)
    {
        llOwnerSay("Debug:GenDisplayString:Entered");
    }
    string title = "Recent Visitors\n";
    string display = title;
    integer nameIndex = llGetListLength(todaysVisitors)-1;
    for (nameIndex; nameIndex >= 0; nameIndex--)
    {
        display += llList2String(todaysVisitors, nameIndex);
        display += "\n";
    }
    if (debug)
    {
        llOwnerSay("Debug:GenDisplayString:DisplayString: " + display);
    }
    return display;
}

default
{
    state_entry()
    {
        SetUpListeners();
        UpdateDisplayText();
    }

    listen(integer channel, string name, key id, string message)
    {//listens on the set channels, then depending on the heard channel sends the message for processing. 
        if(debug)
        {
            llOwnerSay("Debug:Listen:Message: message");
        }
        if (llGetOwner() == llGetOwnerKey(id) && channel == displayComsChannel)
        {
            if (debug)
            {
                llOwnerSay("Debug:Listen:IsOwner And Correct Channel");
            }
            ProcessListenMessage(message);
        } //close if sending object is owned by the same person
    }//close listen 
} 
