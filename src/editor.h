#ifndef EDITOR_H
#define EDITOR_H

#include "ts/ast/token.h"
#include "config.h"

#include <QObject>
#include <QPoint>

class Editor : public QObject {
    Q_OBJECT

private:
    std::vector<std::vector<Token>> data;
    std::vector<int> levels;
    QPoint cursor = {0, 0};

    void _setCursorCell(int x, int y);
    int currLevel() const { return levels[cursor.y()]; }
public:
    static Editor* Instance;

    Editor();
    void addToken(TT type, const QString& val = {});

    static const std::vector<std::vector<Token>>& lines()  { return Instance->data; }
    static auto lineCount() { return Instance->data.size(); }
    static int cursorX() { return Instance->cursor.x(); }
    static int cursorY() { return Instance->cursor.y(); }
    static void setCursorCell(int x, int y) { Instance->_setCursorCell(x, y); }
    static int getIndentation(size_t lvl) { return Instance->levels[lvl]; }


public slots:
    void run();
    QString getFontFamSans() const;
    QString getFontFamMono() const;

    void cursorLeft();
    void cursorRight();
    void del();
    QPoint getCursor() const { return cursor; }
    void setCursorUnsafe(QPoint p) { cursor = p; }

    void decrementIndent();
    void addIndent();
    void addNewLine();

    // clang-format off
    void addVariadic()                   { addToken(TT::Variadic); }
    void addComma()                      { addToken(TT::Comma); }
    void addProp()                       { addToken(TT::Prop); }
    void addElif()                       { addToken(TT::Elif); }
    void addStruct()                     { addToken(TT::Struct); }
    void addModule()                     { addToken(TT::Module); }
    void addImport()                     { addToken(TT::Import); }

    void addTrue()                       { addToken(TT::True); }
    void addFalse()                      { addToken(TT::False); }
    void addNil()                        { addToken(TT::Nil); }
    void addIf()                         { addToken(TT::If); }
    void addElse()                       { addToken(TT::Else); }
    void addBreak()                      { addToken(TT::Break); }
    void addContinue()                   { addToken(TT::Continue); }
    void addWhile()                      { addToken(TT::While); }
    void addFor()                        { addToken(TT::For); }
    void addIn()                         { addToken(TT::In); }
    void addFun()                        { addToken(TT::Fun); }
    void addReturn()                     { addToken(TT::Return); }
    void addIdentifier(const QString& s) { addToken(TT::Identifier, s); }
    void addNumber(const QString& s)     { addToken(TT::Number, s); }
    void addString(const QString& s)     { addToken(TT::String, s); }
    void addLambda()                     { addToken(TT::Lambda); }
    void addArrow()                      { addToken(TT::Arrow); }
    void addLParen()                     { addToken(TT::LParen); }
    void addRParen()                     { addToken(TT::RParen); }
    void addLSquare()                    { addToken(TT::LSquare); }
    void addRSquare()                    { addToken(TT::RSquare); }
    void addLCurly()                     { addToken(TT::LCurly); }
    void addRCurly()                     { addToken(TT::RCurly); }
    void addDot()                        { addToken(TT::Dot); }
    void addInc()                        { addToken(TT::Inc); }
    void addDec()                        { addToken(TT::Dec); }
    void addPlus()                       { addToken(TT::Plus); }
    void addMinus()                      { addToken(TT::Minus); }
    void addMply()                       { addToken(TT::Mply); }
    void addDiv()                        { addToken(TT::Div); }
    void addIntDiv()                     { addToken(TT::IntDiv); }
    void addMod()                        { addToken(TT::Mod); }
    void addPow()                        { addToken(TT::Pow); }
    void addEq()                         { addToken(TT::Eq); }
    void addNe()                         { addToken(TT::Ne); }
    void addLt()                         { addToken(TT::Lt); }
    void addGt()                         { addToken(TT::Gt); }
    void addLe()                         { addToken(TT::Le); }
    void addGe()                         { addToken(TT::Ge); }
    void addAnd()                        { addToken(TT::And); }
    void addOr()                         { addToken(TT::Or); }
    void addNot()                        { addToken(TT::Not); }
    void addXor()                        { addToken(TT::Xor); }
    void addBAnd()                       { addToken(TT::BAnd); }
    void addBOr()                        { addToken(TT::BOr); }
    void addLsh()                        { addToken(TT::Lsh); }
    void addRsh()                        { addToken(TT::Rsh); }
    void addTilde()                      { addToken(TT::Tilde); }
    void addAssign()                     { addToken(TT::Assign); }
    void addQuestion()                   { addToken(TT::Question); }
    void addColon()                      { addToken(TT::Colon); }
    void addCatEq()                      { addToken(TT::CatEq); }
    void addPlusEq()                     { addToken(TT::PlusEq); }
    void addMinusEq()                    { addToken(TT::MinusEq); }
    void addMplyEq()                     { addToken(TT::MplyEq); }
    void addDivEq()                      { addToken(TT::DivEq); }
    void addIntDivEq()                   { addToken(TT::IntDivEq); }
    void addModEq()                      { addToken(TT::ModEq); }
    void addPowEq()                      { addToken(TT::PowEq); }
    void addLshEq()                      { addToken(TT::LshEq); }
    void addRshEq()                      { addToken(TT::RshEq); }
    void addAndEq()                      { addToken(TT::AndEq); }
    void addXorEq()                      { addToken(TT::XorEq); }
    void addOrEq()                       { addToken(TT::OrEq); }
    // clang-format on
};


#endif
