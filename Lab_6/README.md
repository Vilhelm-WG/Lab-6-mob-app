# Каталог книг (SwiftUI + Firebase)

iOS 17+, Xcode 15+. Хмарна БД — Cloud Firestore, авторизація — Firebase Authentication (email/пароль).

## Ролі
| Роль | Можливості |
|---|---|
| Гість (не авторизований) | Перегляд каталогу, вибір рубрики, обкладинка/назва/автори/сторінки. Короткий зміст заблоковано |
| Користувач (авторизований) | Усе вище + короткий зміст книги |
| Адміністратор | Усе вище + додавання (+), редагування й видалення (свайп) книг |

## Налаштування
1. Створіть проєкт у [Firebase Console](https://console.firebase.google.com), додайте iOS-застосунок (Bundle ID = ваш), завантажте `GoogleService-Info.plist` і додайте його в Xcode-проєкт.
2. Authentication → Sign-in method → увімкніть **Email/Password**.
3. Firestore Database → створіть базу, у вкладці Rules вставте вміст `firestore.rules`.
4. Xcode: File → Add Package Dependencies → `https://github.com/firebase/firebase-ios-sdk`, додайте: **FirebaseAuth**, **FirebaseFirestore**, **FirebaseCore**.
5. Додайте файли `*.swift` у таргет.

## Створення адміністратора
1. Зареєструйте користувача в застосунку.
2. У Firestore відкрийте `users/{uid}` цього користувача і змініть поле `role` на `admin`.

## Структура БД
- `users/{uid}`: `email`, `role` (`user` | `admin`)
- `categories/{id}`: `name`
- `books/{id}`: `title`, `authors` (масив рядків), `pages` (число), `category` (рядок = name рубрики), `coverURL`, `summary`

Перші книги й рубрики додайте через адмін-акаунт у застосунку (кнопка «+»).
