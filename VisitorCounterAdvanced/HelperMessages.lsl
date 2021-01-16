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
list Helpers = [];

ProcessInstructionLine(string instruction, string data)
{
    if (llToLower(instruction) == "helper")
    {
        Helpers += data;
    }
}

string CleanUpString(string inputString)

{ 

    string cleanString = llStringTrim( llToLower(inputString), STRING_TRIM );

    return cleanString;   

}

 

ReadConfigCards(string notecardName)

{   //Reads the named config card if it exists

    if (llGetInventoryType(notecardName) == INVENTORY_NOTECARD)

    {   //only come here if the name notecard actually exists, otherwise give the user an error

        integer notecardLength = osGetNumberOfNotecardLines(notecardName); //gets the length of the notecard

        integer index; //defines the index for the next line

        for (index = 0; index < notecardLength; ++index)

        {    //loops through the notecard line by line  

            string currentLine = osGetNotecardLine(notecardName,index); //contents of the current line exactly as it is in the notecard

            string firstChar = llGetSubString(currentLine, 0,0); //gets the first character of this line

            integer equalsIndex = llSubStringIndex(currentLine, "="); //gets the position of hte equals sign on this line if it exists

            if (currentLine != "" && firstChar != "#" && equalsIndex != -1 )

            {   //only come here if the line has content, it does not start with # and it contains an equal sign

                string instruction = llGetSubString (currentLine, 0, equalsIndex-1); //everything before the equals sign

                string data = llGetSubString(currentLine, equalsIndex+1, -1); //everything after the equals sign    

                instruction = CleanUpString (instruction); //sends the instruvtion to the cleanup method to remove white space and turn to lower case

                data = CleanUpString (data); //sends the data to the cleanup method to remove white space and turn to lower case

                ProcessInstructionLine(instruction, data); //sends the instruction and the data to the Process instruction method

            }//close if the line is valid

            else

            {

                if ( (currentLine != "") && (firstChar != "#") && (equalsIndex == -1))

                {

                    llOwnerSay("Line number: " + (string)index + " is malformed. It is not blank, and does not begin with a #, yet it contains no equals sign.");

                }

            }

        }

    }//close if the notecard exists

    else 

    {   //the named notecard does not exist, send an error to the user. 

        llOwnerSay ("The notecard called " + notecardName + " is missing, please address this");

    }//close error the notecard does not exist

}//close read config card. 

MessageHelpers(string aviUUID)
{
    integer index;
    for (index = 0; index < llGetListLength(Helpers); index++)
    {
        string pre = "hop://fireandicegrid.net:8002/app/agent/";
        string tail = "/about";
        string message = pre + aviUUID + tail + " has entered welcome for the first time today"; 
        llInstantMessage(llList2Key(Helpers, index), message);
    }
    
}

default

{
    changed(integer change)
    {
        if (change & CHANGED_INVENTORY) //note that it's & and not &&... it's bitwise!
        {
            llResetScript();
        }
    }
        
    state_entry()

    {   //main entry point of the script, this runs when the script starts

        ReadConfigCards("Helpers"); //calls the read config card method passing the name of the card defined in the global variables above

    }//close state entry

    link_message(integer Sender, integer Number, string String, key Key) // This script is in the object too.
    {
        if (Number == 93827334)
        {
            MessageHelpers(String);
        }
    }
 
}//close default
