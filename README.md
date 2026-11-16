# IVORY & BURGUNDY — Wedding Invitation v2.0

A mobile-first static wedding invitation for GitHub Pages with an online, authenticated Host Studio powered by **Supabase Auth + Postgres RLS + Supabase Storage**.

## What's included

- `index.html`, `style.css`, `app.js`: public invitation (cover, floating 囍, sweeping opening button, music, 9 horizontal sliding highlights, expandable album, calendar & countdown, Google Maps, optional gift QR, thank-you).
- `studio/index.html`, `studio/studio.css`, `studio/studio.js`: online editor with authenticated login, content panels, media uploads, real-time iframe preview, publish, local backup JSON and drafts.
- `default-data.js`: example data (names/event from the public sample invitation; **photos are illustrative stock**).
- `config.js`: PUBLIC Supabase URL and publishable key only.
- `setup/supabase.sql`: RLS policies, public content table, admin membership table and storage policies.

## Quick demo / first view

1. Extract ZIP. Open `index.html` locally in Chrome, or upload all site files to a GitHub repository to use GitHub Pages.
2. Click **MỞ THIỆP CƯỚI** to view animations. Music does not play until a Host uploads an MP3 and publishes it.
3. Visit `studio/index.html`, click **Xem thử Host Studio ở chế độ demo** to try the editor (no online publishing).

**Note:** Without Supabase, online login/publishing is NOT enabled. GitHub Pages alone cannot securely authenticate a Host or persist edits.

## Enable the real online Host Studio (one-time)

1. Create a Supabase project at https://supabase.com. Keep your account credentials private.
2. In **Authentication → Users**, create/invite the Host's email user (set a secure password), and copy the user's UUID. Disable public sign-ups if you only want a private admin.
3. In **SQL Editor**, run `setup/supabase.sql`.
4. Run this additional SQL, substituting the **real UUID** (NOT the email):

   ```sql
   insert into public.wedding_admins (user_id)
   values ('YOUR-REAL-AUTH-USER-UUID');
   ```

5. In Supabase **Connect / Project settings → API**, copy **Project URL** and **publishable/anon key**. Edit `config.js`:

   ```js
   window.WEDDING_BACKEND = {
     url: 'https://YOURPROJECT.supabase.co',
     publishableKey: 'YOUR_PUBLIC_PUBLISHABLE_KEY'
   };
   ```

   Publishable/anon keys are designed for browser exposure when Row Level Security is configured. **Never put any secret / service_role key in this file.**
6. Upload all project files (including `studio/` and `setup/` optionally — recommend not publishing `setup/`) to your GitHub repository; `index.html` must be in the root. Configure **Settings → Pages → Deploy from a branch → main / (root)**.
7. Visit `https://USERNAME.github.io/REPOSITORY/studio/`, sign in as Host, edit, upload photos and MP3, and click **Xuất bản ngay**. Visitors at the public URL will see updates after reloading; you do **not** need to push to GitHub for each edit.
8. Test as an unlogged-in visitor: public invitation is readable, `/studio/` shows login only; test a second non-admin user (must not publish). SQL policies enforce admin-only writes server-side.

**Important:** `studio/` code can be inspected (as with any browser application). The protection is on Supabase Auth and RLS; unauthorized users cannot update data or upload media. Do not confuse a hidden URL with security. All images and QR codes are publicly viewable. Supabase's free tier, bandwidth and storage limits may change.

## Content rights & limitations

- Names, event date and location in `default-data.js` are derived from a publicly visible invitation for demonstration. The photos here are stock illustration URLs, **not copied from the reference wedding album**. Only publish photos/QR codes/music when authorized.
- Gift box displays QR pictures, but the app does not read bank/payment records or record guest data.
- Background MP3 starts on the explicit opening click (modern browser policy); browsers may still reject certain codecs or playback.
- Live preview deliberately does not write data. `Xuất bản ngay` publishes immediately; the service reads the single `wedding_content` row.
- The initial clock target is November 28, 2026 08:00 in the **viewer's timezone** if parsed by local date; for invited guests in Vietnam, dates render correctly. If your guests are overseas, adapt the target to Asia/Ho_Chi_Minh.
- Uploaded media files are public; consider image compression before uploading to keep the page fast.

## GitHub Pages folder layout

```
index.html
style.css
app.js
config.js
default-data.js
studio/
  index.html
  studio.css
  studio.js
```

## Security notes

- Public invitation row is intentionally readable by anyone (`SELECT`). Only host user UUIDs in `wedding_admins` can INSERT/UPDATE it.
- Public asset bucket is viewable by everyone, only the Host can upload/update/delete under the defined policies.
- Never store a secret key, admin password or private information inside client-side files, JSON, or image assets.
- For stronger administration, turn on Supabase MFA for Host accounts and restrict password/email access with your chosen authentication controls.
