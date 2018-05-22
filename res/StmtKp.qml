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
        ["<-",   function(){ editor.cursorLeft(); } ],
        ["->",   function(){ editor.cursorRight() ;} ],
        ["undo", function(){}],
        ["redo", function(){}],
        ["del",  function(){ editor.del(); } ],
    ]
    quickPerc: 0.1

    sizeX: 3
    sizeY: 3
    perc: 0.108 * sizeY
    btnData: [
        ["if", function(){
            editor.add_if();
            editor.addParenBody();
            back();
        }],
        ["else", function(){
            editor.add_else();
            editor.addBody();
            back();
        }],
        ["fun", function(){
            /* fun [](|) {
               }
            */
            editor.add_fun();
            editor.addSquarePair();
            editor.cursorRight();
            editor.addParenBody();
            back();
        }],

        ["while", function(){
            editor.add_while();
            editor.addParenBody();
            back();
        }],
        ["for", function(){
            editor.add_for();
            editor.addParenBody();
            back();
        }],
        ["in",       function(){ editor.add_in(); back(); }],
        ["return",   function(){ editor.add_return(); back(); }],
        ["break",    function(){ editor.add_break(); back(); }],
        ["continue", function(){ editor.add_continue(); back(); }],

    ]
}
