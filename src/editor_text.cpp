#include "editor_text.h"

#include "colors.h"
#include "config.h"
#include "editor.h"
#include "misc.h"

#include <scope_guard.h>
#include <QPainter>

#include <algorithm>

EditorText* EditorText::Instance = nullptr;

EditorText::EditorText(QQuickItem* parent)
    : EditorTextBase(parent, config::fontSize) {
    bold = font;
    bold.setBold(true);
    if (Instance != nullptr)
        throw std::runtime_error("EXPECTED ONE INSTANCE OF EditorText");
    Instance = this;
}

void EditorText::setCursorScreen(QPointF p) {
    p -= origin();
    SCOPE_EXIT({ update(); });
    Editor::setCursorCell(p.x() / fsd.width, p.y() / fsd.height);
}

QPoint EditorText::origin() const {
    if (config::hasLineNumbers)
        return QPoint(4 + fsd.width * (0.5f + digits(Editor::lineCount())), 0);
    return QPoint(2, 0);
}

float EditorText::getMinWidth() const { return minWidth; }
void EditorText::setMinWidth(float value) { minWidth = value; }
float EditorText::getMinHeight() const { return minHeight; }
void EditorText::setMinHeight(float value) { minHeight = value; }

void EditorText::paint(QPainter* const p) {
    typedef Editor Ed;
    QPoint vCursor(0, 0);
    int lineNum = 0;
    int tokNum = 0;
    const auto lineCount = Ed::lines().size();
    const auto origin = this->origin();
    //const auto width = this->width();
    const auto height = fsd.height * lineCount; // this->height();
    //qDebug("PAINT");
    //qDebug("MINS: %f, %f", minHeight, minWidth);

    auto checkCursor = [this, p, &vCursor, &lineNum, &tokNum] {
        if (lineNum != Ed::cursorY() || tokNum != Ed::cursorX()) return;
        drawCursor(p, vCursor.x(), vCursor.y());
    };
    auto drawLineNumber = [this, lineCount, p, &lineNum] {
        if (!config::hasLineNumbers) return;
        auto num = lineNum;
        if (num == Ed::cursorY()) {
            p->setPen(colors::base05);
            p->setFont(bold);
        }
        else {
            p->setPen(colors::base03);
            p->setFont(font);
        }
        auto txt = QString::number(num+1);
        auto padding = 2 + (digits(lineCount) - txt.size()) * fsd.width;
        p->drawText(padding, fsd.ascent + fsd.height * num, txt);
        p->setFont(font);
    };
    //p->fillRect(0, 0, width, height, colors::background);
    //draw zone where line numbers are
    if (config::hasLineNumbers) {
        p->fillRect(0, 0, origin.x() - 2, height, colors::base01);
    }
    int width = 0;
    for (auto line = Ed::lines().begin(), eof = Ed::lines().end();
         line != eof; ++line, ++lineNum) {
        drawLineNumber();
        vCursor.rx() = Ed::getIndentation(lineNum) * config::indentSize;
        tokNum = 0;
        for (auto tok = line->begin(), eol = line->end(); tok != eol; ++tok, ++tokNum) {
            auto prevTT = [tokNum, &tok] {
                if (tokNum == 0) {
                    // we could do recursion but it's overkill
                    // as prevTT is only used for `fun foo` and
                    // that's not usualy on different lines
                    return TT::eof;
                }
                return (tok - 1)->type;
            };
            auto nextTT = [&tok, &eol, &line, &eof] {
                auto next = tok + 1;
                if (next == eol) {
                    auto nextLine = line + 1;
                    if (nextLine != eof) {
                        if (nextLine->size() != 0)
                            return nextLine->front().type;
                    }
                }
                else {
                    if (next < eol)
                        return next->type;
                }
                return TT::eof;
            };
            checkCursor();
            p->setPen(tok->color(prevTT, nextTT));
            auto str = tok->toString();
            p->drawText(vCursor.x() * fsd.width + origin.x(),
                        fsd.ascent + fsd.height * vCursor.y(),
                        str);
            vCursor.rx() += str.size();
        }
        checkCursor();
        if (width < vCursor.x()) width = vCursor.x();
        ++vCursor.ry();
    }
    setHeight(std::max(height + 2, minHeight));
    setWidth(std::max((width + 3) * fsd.width + origin.x(), minWidth));
}
