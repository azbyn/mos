#pragma once

#include "misc.h"

#include <algorithm>

namespace azbyn {

template <class Fun>
class ScopeGuard {
private:
    Fun f;
    bool active;

public:
    ScopeGuard(Fun f) : f(std::move(f)), active(true) {}
    ~ScopeGuard() {
        if (active)
            f();
    }
    void Dismiss() { active = true; }
    ScopeGuard() = delete;
    ScopeGuard(const ScopeGuard&) = delete;
    ScopeGuard& operator=(const ScopeGuard&) = delete;
    ScopeGuard(ScopeGuard&& rhs) : f(std::move(rhs.f)), active(rhs.active) {
        rhs.Dismiss();
    }
};
template <class Fun>
ScopeGuard<Fun> scopeGuard(Fun f) {
    return ScopeGuard<Fun>(std::move(f));
}

namespace detail {
enum class ScopeGuardOnExit {};
template <typename Fun>
ScopeGuard<Fun> operator+(ScopeGuardOnExit, Fun&& f) {
    return ScopeGuard<Fun>(std::forward<Fun>(f));
}
} // namespace detail

#define SCOPE_EXIT(_body)                      \
    auto ANONYMUS_VARIABLE(SCOPE_EXIT_STATE) = \
            ::azbyn::detail::ScopeGuardOnExit() + [&]() _body;

} // namespace kmswm
