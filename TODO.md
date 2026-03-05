# Fix Register Navigation - Option 2 Plan

## Information Gathered
- The issue is that `/register` navigation fails because the register component is in `app/(auth)/register.tsx` but there's no root-level `app/register.tsx`
- Login works because there's `app/login.tsx` at root level
- Navigation is handled in `app/_layout.tsx` with a Stack navigator
- Onboarding page (`app/(onboarding)/index.tsx`) uses `router.push('/login')` and `router.push('/register')`

## Plan

### Step 1: Create `app/(auth)/_layout.tsx` ✅
- Create a Stack navigator for the auth group
- Register both `login` and `register` screens

### Step 2: Update `app/(onboarding)/index.tsx` ✅
- Change `router.push('/login')` to `router.push('/(auth)/login')`
- Change `router.push('/register')` to `router.push('/(auth)/register')`

### Step 3: Update `app/_layout.tsx` ✅
- Remove the old `<Stack.Screen name="login" />` and `<Stack.Screen name="register" />` since they're now in the auth group
- Add `<Stack.Screen name="(auth)" options={{ headerShown: false }} />`

## Files to be Edited
1. ✅ Create: `app/(auth)/_layout.tsx`
2. ✅ Edit: `app/(onboarding)/index.tsx`
3. ✅ Edit: `app/_layout.tsx`

## COMPLETED

