# Migration Guide: Netlify → GitHub Pages

Since you moved your app from **Netlify** to **GitHub Pages**, your "Allowed URLs" in Supabase and Kakao are likely still pointing to the old Netlify link. You must update them for the app to work.

## 1. Update Kakao Developers Console
**Goal:** Allow your new GitHub URL to access Kakao Login.

1.  Log in to [Kakao Developers](https://developers.kakao.com/).
2.  Go to **My Application > SINO**.
3.  Select **Platform** from the left menu.
4.  Under **Web**, click **Register Web Site Domain**.
    *   **Delete/Remove** the old Netlify URL.
    *   **Add** exactly this: `https://shukurillo0526.github.io`
    *   *(Note: Do not add `/SINO/` here, just the main domain)*.
5.  Click **Save**.
6.  (If used) Go to **Kakao Login > Redirect URI** in the left menu.
    *   Add: `https://shukurillo0526.github.io/SINO/`

## 2. Update Supabase Authentication
**Goal:** Allow Supabase to redirect users back to your GitHub app after login.

1.  Log in to [Supabase Dashboard](https://supabase.com/dashboard).
2.  Select your project (`kvmoirajybmjyrrgdsld`).
3.  Go to **Authentication** (icon on the left) > **URL Configuration**.
4.  **Site URL**:
    *   Change this to: `https://shukurillo0526.github.io/SINO/`
5.  **Redirect URLs**:
    *   Add: `https://shukurillo0526.github.io/SINO/`
    *   Add: `https://shukurillo0526.github.io/SINO/auth/callback` (Common fallback)
    *   *You can remove the old Netlify URLs from here.*
6.  Click **Save**.

## 3. Why this matters
*   **Redirect Mismatch Error:** If these aren't updated, trying to log in will show an error saying "Redirect URI mismatch" or simply fail silently because the service doesn't trust the new GitHub website.
