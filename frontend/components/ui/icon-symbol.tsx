import MaterialIcons from '@expo/vector-icons/MaterialIcons';
import { SymbolWeight } from 'expo-symbols';
import { ComponentProps } from 'react';
import { OpaqueColorValue, Platform, View, type StyleProp, type ViewStyle } from 'react-native';

// ✅ iOS-specific import (Metro resolves automatically)
const IconSymbolIOS = Platform.OS === 'ios' ? require('./icon-symbol.ios').IconSymbol : null;

// ✅ Types - ViewStyle for transform support
type MaterialIconName = ComponentProps<typeof MaterialIcons>['name'];
type IconMapping = Record<string, MaterialIconName>;

const MAPPING: IconMapping = {
  'house.fill': 'home',
  'paperplane.fill': 'send', 
  'qr-code-scanner.fill': 'qr-code-scanner',
  'chevron.left.forwardslash.chevron.right': 'code',
  'chevron.right': 'chevron-right',
};

type IconSymbolName = keyof typeof MAPPING;

export type IconSymbolProps = {
  name: IconSymbolName;
  size?: number;
  color: string | OpaqueColorValue;
  style?: StyleProp<ViewStyle>;  // ✅ Changed to ViewStyle
  weight?: SymbolWeight;
};

/**
 * Cross-platform: SF Symbols (iOS), MaterialIcons (Android/Web)
 */
export function IconSymbol({
  name,
  size = 24,
  color,
  style,
  weight,
}: IconSymbolProps) {
  // ✅ iOS: Native SF Symbols
  if (Platform.OS === 'ios' && IconSymbolIOS) {
    return (
      <IconSymbolIOS
        name={name}
        size={size}
        color={color as string}
        style={style}
        weight={weight}
      />
    );
  }

  // ✅ Android/Web: MaterialIcons with size wrapper
  return (
    <View style={[{ width: size, height: size }, style]}>
      <MaterialIcons
        name={MAPPING[name]}
        size={size}
        color={color}
      />
    </View>
  );
}
