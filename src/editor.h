#ifndef EDITOR_H
#define EDITOR_H

#include "ts/ast/token.h"

#include <QObject>
#include <QPoint>
#include "config.h"

class Editor : public QObject {
    Q_OBJECT

private:
    std::vector<std::vector<Token>> data;
    std::vector<int> levels;
    QPoint cursor = {0, 0};

    void updateLevels();
    void _setCursorCell(int x, int y);
public:
    static Editor* Instance;

    Editor();
    void addToken(TT type, const QString& val = {});
    void puts(const QString& value);

    static const std::vector<std::vector<Token>>& lines()  { return Instance->data; }
    static auto lineCount() { return Instance->data.size(); }
    static int cursorX() { return Instance->cursor.x(); }
    static int cursorY() { return Instance->cursor.y(); }
    static int getIndentation(size_t line) { return Instance->levels[line]; }
    static void setCursorCell(int x, int y) { Instance->_setCursorCell(x, y); }


public slots:
    void run();
    QString getFontName() const;

    void cursorLeft();
    void cursorRight();
    void del();
    QPoint getCursor() const { return cursor; }
    void setCursorUnsafe(QPoint p) { cursor = p; }

    void add_newLine();

    // clang-format off
    void add_terminator()                 { addToken(TT::terminator); }
    void add_comma()                      { addToken(TT::comma); }
    void add_true()                       { addToken(TT::true_); }
    void add_false()                      { addToken(TT::false_); }
    void add_nil()                        { addToken(TT::nil); }
    void add_if()                         { addToken(TT::if_); }
    void add_else()                       { addToken(TT::else_); }
    void add_break()                      { addToken(TT::break_); }
    void add_continue()                   { addToken(TT::continue_); }
    void add_while()                      { addToken(TT::while_); }
    void add_for()                        { addToken(TT::for_); }
    void add_in()                         { addToken(TT::in); }
    void add_fun()                        { addToken(TT::fun); }
    void add_return()                     { addToken(TT::return_); }
    void add_identifier(const QString& s) { addToken(TT::identifier, s); }
    void add_number(const QString& s)     { addToken(TT::number, s); }
    void add_string(const QString& s)     { addToken(TT::string, s); }
    void add_lambda()                     { addToken(TT::lambda); }
    void add_arrow()                      { addToken(TT::arrow); }
    void add_lParen()                     { addToken(TT::lParen); }
    void add_rParen()                     { addToken(TT::rParen); }
    void add_lSquare()                    { addToken(TT::lSquare); }
    void add_rSquare()                    { addToken(TT::rSquare); }
    void add_lCurly()                     { addToken(TT::lCurly); }
    void add_rCurly()                     { addToken(TT::rCurly); }
    void add_dot()                        { addToken(TT::dot); }
    void add_inc()                        { addToken(TT::inc); }
    void add_dec()                        { addToken(TT::dec); }
    void add_plus()                       { addToken(TT::plus); }
    void add_minus()                      { addToken(TT::minus); }
    void add_mply()                       { addToken(TT::mply); }
    void add_div()                        { addToken(TT::div); }
    void add_intDiv()                     { addToken(TT::intDiv); }
    void add_mod()                        { addToken(TT::mod); }
    void add_pow()                        { addToken(TT::pow); }
    void add_eq()                         { addToken(TT::eq); }
    void add_ne()                         { addToken(TT::ne); }
    void add_lt()                         { addToken(TT::lt); }
    void add_gt()                         { addToken(TT::gt); }
    void add_le()                         { addToken(TT::le); }
    void add_ge()                         { addToken(TT::ge); }
    void add_and()                        { addToken(TT::and_); }
    void add_or()                         { addToken(TT::or_); }
    void add_not()                        { addToken(TT::not_); }
    void add_xor()                        { addToken(TT::xor_); }
    void add_bAnd()                       { addToken(TT::bAnd); }
    void add_bOr()                        { addToken(TT::bOr); }
    void add_lsh()                        { addToken(TT::lsh); }
    void add_rsh()                        { addToken(TT::rsh); }
    void add_tilde()                      { addToken(TT::tilde); }
    void add_assign()                     { addToken(TT::assign); }
    void add_question()                   { addToken(TT::question); }
    void add_colon()                      { addToken(TT::colon); }
    void add_catEq()                      { addToken(TT::catEq); }
    void add_plusEq()                     { addToken(TT::plusEq); }
    void add_minusEq()                    { addToken(TT::minusEq); }
    void add_mplyEq()                     { addToken(TT::mplyEq); }
    void add_divEq()                      { addToken(TT::divEq); }
    void add_intDivEq()                   { addToken(TT::intDivEq); }
    void add_modEq()                      { addToken(TT::modEq); }
    void add_powEq()                      { addToken(TT::powEq); }
    void add_lshEq()                      { addToken(TT::lshEq); }
    void add_rshEq()                      { addToken(TT::rshEq); }
    void add_andEq()                      { addToken(TT::andEq); }
    void add_xorEq()                      { addToken(TT::xorEq); }
    void add_orEq()                       { addToken(TT::orEq); }
    // clang-format on
public:
signals:
    void setOut(const QString& value);
    void appendOut(const QString& value);
public:
    friend void tsputs(const ushort* sh, size_t len);
};


#endif
