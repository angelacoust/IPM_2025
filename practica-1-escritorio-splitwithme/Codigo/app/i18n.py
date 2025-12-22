import locale as _locale
import gettext
from pathlib import Path

# Carpeta locales y nombre del dominio (.po/.mo)
LOCALE_DIR = Path(__file__).resolve().parent.parent / "locale"
DOMAIN = "SplitWithMe"

_active_locale = "en"
_translation = None


def detect_locale() -> str:
    """Detecta el idioma del sistema ('es' o 'en')."""
    try:
        lang = (_locale.getdefaultlocale()[0] or "").lower()
    except Exception:
        lang = ""
    code = lang.split("_")[0] if lang else ""
    return "es" if code == "es" else "en"


def _install_translation(code: str) -> None:
    """Carga la traducción de gettext para el código dado."""
    global _translation, _active_locale
    _active_locale = code
    _translation = gettext.translation(
        DOMAIN,
        localedir=str(LOCALE_DIR),
        languages=[code],
        fallback=True,
    )


# Inicializar traducción al arrancar
_install_translation(detect_locale())


def set_locale(code: str) -> None:
    """Forzar idioma manualmente ('es' o 'en')."""
    if code not in ("es", "en"):
        code = "en"
    _install_translation(code)


def t(key: str) -> str:
    """Devuelve la traducción de una clave según el idioma activo."""
    if _translation is None:
        _install_translation(detect_locale())
    return _translation.gettext(key)


def _(key: str) -> str:
    """Alias estilo gettext (compatibilidad con _('clave'))."""
    return t(key)

