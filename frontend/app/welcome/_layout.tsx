import { Stack } from 'expo-router';

export default function AuthLandingLayout() {
  return (
    <Stack >
      <Stack.Screen
        name="index"        // <== HARUS "index"
        options={{
          headerShown: false, // boleh dihapus karena sudah di screenOptions
        }}
      />
    </Stack>
  );
}
