# SINO Integration Guide: KakaoTalk & Supabase

This guide explains how to configure **KakaoTalk Login** and **Supabase Database** for your SINO application.

## 1. Supabase Setup (Database & Auth)

Supabase handles user data (moods, tasks) and authentication.

### **Step A: Create Project**
1.  Go to [Supabase Dashboard](https://supabase.com/dashboard).
2.  Click **New Project**.
3.  Enter a Name (e.g., `sino-app`) and Database Password.
4.  Choose a Region closest to your users (e.g., `Seoul` or `Tokyo`).

### **Step B: Get API Keys**
1.  In your project, go to **Settings (Cog icon) > API**.
2.  Copy the **Project URL**.
3.  Copy the **`anon` public key**.

### **Step C: Configure GitHub Secrets (For Deployment)**
Since your app is hosted on GitHub Pages, you must not put real keys in the code.
1.  Go to your GitHub Repo > **Settings > Secrets and variables > Actions**.
2.  Add a New Repository Secret:
    *   Name: `SUPABASE_URL`
    *   Value: *(Your Project URL)*
3.  Add another Secret:
    *   Name: `SUPABASE_ANON_KEY`
    *   Value: *(Your `anon` key)*

### **Step D: Create Tables**
Run this SQL in the Supabase **SQL Editor** to set up your tables:

```sql
-- Moods Table
create table moods (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  mood text not null,
  source text,
  sentiment_score float,
  context text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Row Level Security (RLS) - Protect Data
alter table moods enable row level security;
create policy "Users manage their own moods" on moods
  for all using (auth.uid() = user_id);
```

---

## 2. KakaoTalk Login Setup

Allows users to sign in with their Kakao account.

### **Step A: Developer Console**
1.  Go to [Kakao Developers](https://developers.kakao.com/).
2.  Log in and click **My Application > Add an application**.
3.  Name it `SINO` and enter your company name.

### **Step B: Get App Keys**
1.  In your app dashboard, go to **App Keys**.
2.  Copy the **Native App Key** (for Android/iOS).
3.  Copy the **JavaScript Key** (for Web).

### **Step C: Configure Platform (Web)**
1.  Go to **Platform > Web** in the sidebar.
2.  Click **Register Web Site Domain**.
3.  Add your GitHub Pages URL: `https://shukurillo0526.github.io`
4.  (Optional) Add `http://localhost:port` for local testing.

### **Step D: Configure Code (Web)**
Open `web/index.html` and find the Kakao script setup (if present) or add it:
```html
<script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
<script>
    // Initialize Kakao SDK
    Kakao.init('YOUR_JAVASCRIPT_KEY'); 
</script>
```

### **Step E: Configure Flutter**
In `lib/main.dart` or your auth initialization logic:
```dart
KakaoSdk.init(
  nativeAppKey: 'YOUR_NATIVE_APP_KEY',
  javaScriptAppKey: 'YOUR_JAVASCRIPT_KEY',
);
```

## 3. GitHub Actions Update
To inject these keys during your automated build, update `.github/workflows/deploy_web.yml`:

```yaml
- name: Create .env file
  run: |
    echo "SUPABASE_URL=${{ secrets.SUPABASE_URL }}" > .env
    echo "SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }}" >> .env
    echo "KAKAO_JS_KEY=${{ secrets.KAKAO_JS_KEY }}" >> .env
```
*(Make sure to add `KAKAO_JS_KEY` to your GitHub Secrets too!)*
