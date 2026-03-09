**Aplikacja moblina na (Android) pisana we flutterze.
**Potwierdzenie zasad pracy

***

## README dla `flutterarchitektura` (wrzuć do `filmy_pl/README.md`)

```markdown
# filmy_pl

Aplikacja mobilna na Androida napisana w Flutter. Łączy się z backendem 
z repo videoweb. Pozwala przeglądać i streamować filmy, komentować oraz lajkować.

Backend repo: https://github.com/terapeutaLPG/videoweb

## Stack
- Flutter / Dart
- platforma: Android (iOS odpada – brak konta developera)
- komunikacja z API przez HTTP (Bearer token)

## Funkcje
- rejestracja i logowanie
- lista filmów z miniaturkami
- odtwarzanie filmów (streaming)
- komentowanie filmów
- lajkowanie filmów

## Uruchomienie
```bash
cd filmy_pl
flutter pub get
flutter run
