import QtQuick 2.0
import QtQuick.Controls.Styles 1.0
import ts 1.0

Keypad {
    /*function okBttn() {
        return btnAt(11);
    }*/
    /*
    Component.onCompleted: {
        okBttn().font.bold = true;
        invalidate();
    }
    function validate() {
        okBttn().txtColor = "green";
    }
    function invalidate() {
        okBttn().txtColor = "red";
    }
*/
    function back(){
        ep.setCurr(KeypadType.Main);
    }

    quickData: [
        ["back", function(){ back(); } ],
        ["<-",   function(){ editorText.cursorLeft(); } ],
        ["->",   function(){ editorText.cursorRight() ;} ],
        ["undo", function(){}],
        ["redo", function(){}],
        ["del",  function(){ editorText.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 3
    sizeY: 3
    perc: 0.108 * sizeY
    btnData: [
        ["if", function(){
            editorText.add_if();
            editorText.addParenBody();
            back();
        }],
        ["else", function(){
            editorText.add_else();
            editorText.addBody();
            back();
        }],
        ["fun", function(){
            /* fun [](|) {
               }
            */
            editorText.add_fun();
            editorText.addSquarePair();
            editorText.cursorRight();
            editorText.addParenBody();
            back();
        }],

        ["while", function(){
            editorText.add_while();
            editorText.addParenBody();
            back();
        }],
        ["for", function(){
            editorText.add_for();
            editorText.addParenBody();
            back();
        }],
        ["in",       function(){ editorText.add_in(); back(); }],

        ["return",   function(){ editorText.add_return(); back(); }],
        ["break",    function(){ editorText.add_break(); back(); }],
        ["continue", function(){ editorText.add_continue(); back(); }],

    ]
}
