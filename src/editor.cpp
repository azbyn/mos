#include "editor.h"

#include "editor_text.h"
#include "out_text.h"
#include "mos/ast/lexer.h"

void mosrun(const DToken* ptr, int len);

static void update() {
    EditorText::Instance->update();
}

Editor* Editor::Instance = nullptr;
Editor::Editor() : data{{},} {
    if (Instance != nullptr) throw "EXPECTED ONE INSTANCE OF Editor";
    Instance = this;
#ifndef ANDROID
    Lexer(&data, &levels, config::file);
#endif
    if (EditorText::Instance)
        update();
    levels.resize(data.size());
}
void Editor::addToken(TT type, const QString& val) {
    auto& v = data[cursor.y()];
    qDebug() << "AddToken:" << (int)type << "," << val;
    v.emplace(v.begin() + cursor.x(), Token(type, val));
    ++cursor.rx();
    update();
}
void Editor::addIndent() {
    ++levels[cursor.y()];
    update();
}
void Editor::decrementIndent() {
    Q_ASSERT(levels[cursor.y()] > 0);
    --levels[cursor.y()];
    update();
}

void Editor::cursorLeft() {
    if (cursor.x() == 0) {
        if (cursor.y() == 0) return;
        auto v = data[--cursor.ry()];
        cursor.rx() = v.size();
    }
    else {
        --cursor.rx();
    }
    update();
}
void Editor::cursorRight() {
    auto& v = data[cursor.y()];
    if ((size_t)cursor.x() == v.size()) {
        if ((size_t)cursor.y() == data.size() - 1) return;
        ++cursor.ry();
        cursor.rx() = 0;
    }
    else {
        ++cursor.rx();
    }
    update();
}
void Editor::del() {
    if (cursor.x() == 0) {
        if (levels[cursor.y()] != 0) {
            decrementIndent();
            return;
        }
        if (cursor.y() == 0) return;
        auto old = data.begin() + cursor.y();
        auto& now = data[--cursor.ry()];
        cursor.rx() = now.size();
        now.insert(now.end(), old->begin(), old->end());
        data.erase(old);
        levels.erase(levels.begin() + cursor.y() + 1);
    }
    else {
        auto& v = data[cursor.y()];
        --cursor.rx();
        v.erase(v.begin() + cursor.x());
    }
    update();
}
void Editor::addNewLine() {
    auto l = currLevel();
    if (cursor.x() == 0) {
        levels.insert(levels.begin() + cursor.y(), l);
        data.insert(data.begin() + cursor.y(), std::vector<Token>());
    }
    else {
        auto it = data.begin() + cursor.y();
        if (cursor.x() == (int)it->size()) {
            data.insert(it + 1, std::vector<Token>());
            levels.insert(levels.begin() + cursor.y() + 1, l);
        }
        else {
            data.insert(it + 1, std::vector<Token>(it->begin() + cursor.x(), it->end()));
            levels.insert(levels.begin() + cursor.y() + 1, l + 1);
            auto& v = data[cursor.y()];
            v = std::vector<Token>(v.begin(), v.begin() + cursor.x());
        }
        cursor.rx() = 0;
    }
    ++cursor.ry();
    update();
}
void Editor::run() {
    mosclear();
    //QVector<DToken> toks;
    std::vector<DToken> dtoks;
    int prevLevel = 0;
    size_t i = 0;
    /*for (auto l : levels) {
        qDebug("lvl: %d", l);
        }*/
    bool skipIndentation = false;
    int level;
    qDebug("BEGIN");
    for (auto line = data.begin(), endLine = data.end(); line!=endLine; ++line) {
        level = levels[i];
        //qDebug("[%ld] = %d", i, level);
        //qDebug("prev: %d, lvl: %d ", prevLevel, level);
        //toks.reserve(toks.size() + line.size());
        if (prevLevel != level) {
            //qDebug("diff @%ld", dtoks.size());
            while (prevLevel > level) {
                dtoks.emplace_back(TT::Dedent);

                dtoks.emplace_back(TT::NewLine);
                --prevLevel;
                //qDebug("--%d", level);
            }
            while (prevLevel < level) {
                dtoks.emplace_back(TT::Indent);
                ++prevLevel;
                //qDebug("++%d", level);
            }
        }
    continuation:
        for (auto it = line->begin(), end = line->end(); it != end; ++it) {
            if (skipIndentation) {
                skipIndentation = false;
                while (it->type == TT::Indent || it->type == TT::Dedent)
                    ++it;
            }
#define ADD_EQ(_nrml, _eq)               \
    case TT::_nrml:                      \
        isContinuable = true;                                \
        if (it + 1 != end && (it+1)->type == TT::Assign) {   \
            dtoks.emplace_back(TT::_eq); \
            ++it;                        \
            continue;                    \
        }                                \
        break;
            // if the newline after this gets ignored so that this:
            // var = 1 +
            //       2
            // becomes this:
            // var = 1 + 2
            bool isContinuable = false;
            switch (it->type) {
            case TT::Comma:
            case TT::In:
            case TT::Variadic:
            case TT::Lambda:
            case TT::Arrow:
            case TT::LParen:
            case TT::LSquare:
            case TT::LCurly:
            case TT::Dot:
            case TT::Eq:
            case TT::Ne:
            case TT::Lt:
            case TT::Gt:
            case TT::Le:
            case TT::Ge:
            case TT::Not:
            case TT::BAnd:
            case TT::BOr:
            case TT::Assign:
            case TT::CatEq:
            case TT::PlusEq:
            case TT::MinusEq:
            case TT::MplyEq:
            case TT::DivEq:
            case TT::IntDivEq:
            case TT::ModEq:
            case TT::PowEq:
            case TT::LshEq:
            case TT::RshEq:
            case TT::AndEq:
            case TT::XorEq:
            case TT::OrEq:
                isContinuable = true;
                break;
            ADD_EQ(Plus, PlusEq);
            ADD_EQ(Minus, MinusEq);
            ADD_EQ(Mply, MplyEq);
            ADD_EQ(Tilde, CatEq);
            ADD_EQ(Div, DivEq);
            ADD_EQ(IntDiv, IntDivEq);
            ADD_EQ(Mod, ModEq);
            ADD_EQ(Pow, PowEq);
            ADD_EQ(Lsh, LshEq);
            ADD_EQ(Rsh, RshEq);
            ADD_EQ(And, AndEq);
            ADD_EQ(Xor, XorEq);
            ADD_EQ(Or, OrEq);
            default: break;
            }
#undef ADD_EQ
            dtoks.emplace_back(*it);
            if (isContinuable && it == end -1) {
                qDebug("SKIP");
                ++i;
                ++line;
                skipIndentation = true;
                goto continuation;
            }
        }
        dtoks.emplace_back(TT::NewLine);
        ++i;
        prevLevel = level;
        //toks.insert(toks.end(), line.begin(), line.end());
    }
    level = levels.back();
    while (level > 0) {
        dtoks.emplace_back(TT::Dedent);
        --level;

    }

    //test(DToken(Token(TT::eof, "hello"));
    qDebug("END");

    mosrun(dtoks.data(), dtoks.size());
}

QString Editor::getFontFamSans() const{ return config::fontFamSans; }
QString Editor::getFontFamMono() const{ return config::fontFamMono; }

void Editor::_setCursorCell(int x, int y) {
    if (y < 0) {
        //qDebug("setcurs 0,0");
        cursor = QPoint(0, 0);
    }
    else if (y >= (int)data.size()) {
        //qDebug("setcurs data.size()");
        cursor.ry() = data.size() == 0 ? 0 : (data.size() - 1);
        cursor.rx() = data[cursor.y()].size();
        return;
    }

    auto& vec = data[y];
    auto col = x - (levels[y] * config::indentSize);
    cursor.ry() = y;
    if (col <= 0) {
        //qDebug("setcurs %ld, 0", line);
        cursor.rx() = 0;
        return;
    }

    int prev = 0;
    int curr = 0;
    int i = 0;
    TT prevTT = TT::Eof;
    for (auto& t : vec) {
        prev = curr;
        curr += t.toString().size();

        if (isSpaceBetween(prevTT, t.type))
            ++curr;
        prevTT = t.type;
        if (col > curr) {
            ++i;
            continue;
        }
        auto mid = (curr + prev) * 0.5f;
        cursor.rx() = i + (col >= mid ? 1 : 0);
        if (cursor.x() < 0)
            cursor.rx() = 0;
        return;
    }
    cursor.rx() = vec.size();
    //qDebug("setcurs %ld, $ (%d)", line, cursor.x());
}
