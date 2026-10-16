EARTH ORBIT + SUPABASE

1. In Supabase open Authentication -> Users. Create your admin account if you have not already.
2. In the users list, copy the UID / User UID value for that account (open the user details if needed). It is a UUID like 123e4567-e89b-12d3-a456-426614174000. Do not use email.
3. Open SUPABASE_SETUP.sql. Replace YOUR_ADMIN_AUTH_USER_UUID with the copied UID, keeping the single quotes around it, then run the whole script in SQL Editor.
4. Upload all files from this folder to the GitHub Pages repository.
5. Open the site, trigger the hidden admin gesture, and sign in with the same Supabase Auth email/password.

The numbered placeholder avatar images have been removed. Only the three real profile entries remain; no fake profiles are seeded. The plus markers open a form requiring name and email, with optional description. Public submissions go into public.earth_orbit_requests. Only listed Supabase admins can read, approve, or reject requests.

Important: the public key is intended for frontend use. Never put service_role/secret keys in index.html. Run the SQL before testing requests.
