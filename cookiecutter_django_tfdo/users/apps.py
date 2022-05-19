from django.apps import AppConfig
from django.utils.translation import gettext_lazy as _


class UsersConfig(AppConfig):
    name = "cookiecutter_django_tfdo.users"
    verbose_name = _("Users")

    def ready(self):
        try:
            import cookiecutter_django_tfdo.users.signals  # noqa F401
        except ImportError:
            pass
