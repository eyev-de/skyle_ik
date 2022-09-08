//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

// ignore_for_file: non_constant_identifier_names, constant_identifier_names, camel_case_types, camel_case_extensions, depend_on_referenced_packages

import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'windows_monitor.dart';

final _setupapi = DynamicLibrary.open('setupapi.dll');

enum DIGCF {
  DIGCF_DEFAULT,
  DIGCF_PRESENT,
  DIGCF_ALLCLASSES,
  DIGCF_PROFILE,
  DIGCF_DEVICEINTERFACE;

  int get value {
    switch (this) {
      case DIGCF.DIGCF_DEFAULT:
        return 0x00000001;
      case DIGCF.DIGCF_PRESENT:
        return 0x00000002;
      case DIGCF.DIGCF_ALLCLASSES:
        return 0x00000004;
      case DIGCF.DIGCF_PROFILE:
        return 0x00000008;
      case DIGCF.DIGCF_DEVICEINTERFACE:
        return 0x00000010;
    }
  }
}

// class SP_DEVINFO_DATA extends Struct {
//   @Uint32()
//   external int cbSize;
//   external GUID ClassGuid;
//   @Uint32()
//   external int DevInst;
//   @IntPtr()
//   external int Reserved;
// }

// const int ERROR_NO_MORE_ITEMS = 259;

int _SetupDiGetClassDevsW(Pointer<GUID> ClassGuid, Pointer<Utf16> Enumerator, int hwndParent, DIGCF Flags) {
  final setupDiGetClassDevsW = _setupapi.lookupFunction<
      IntPtr Function(
    Pointer<GUID> ClassGuid,
    Pointer<Utf16> Enumerator,
    IntPtr hwndParent,
    Uint32 Flags,
  ),
      int Function(
    Pointer<GUID> ClassGuid,
    Pointer<Utf16> Enumerator,
    int hwndParent,
    int Flags,
  )>('SetupDiGetClassDevsW');
  return setupDiGetClassDevsW(
    ClassGuid,
    Enumerator,
    hwndParent,
    Flags.value,
  );
}

enum DICS_FLAG {
  DICS_FLAG_GLOBAL,
  DICS_FLAG_CONFIGSPECIFIC,
  DICS_FLAG_CONFIGGENERAL;

  int get value {
    switch (this) {
      case DICS_FLAG.DICS_FLAG_GLOBAL:
        return 0x00000001;
      case DICS_FLAG.DICS_FLAG_CONFIGSPECIFIC:
        return 0x00000002;
      case DICS_FLAG.DICS_FLAG_CONFIGGENERAL:
        return 0x00000004;
    }
  }
}

enum DIREG {
  DIREG_DEV,
  DIREG_DRV,
  DIREG_BOTH;

  int get value {
    switch (this) {
      case DIREG.DIREG_DEV:
        return 0x00000001;
      case DIREG.DIREG_DRV:
        return 0x00000002;
      case DIREG.DIREG_BOTH:
        return 0x00000004;
    }
  }
}

enum REG_RIGHTS {
  KEY_READ,
  KEY_WRITE;

  int get value {
    switch (this) {
      case REG_RIGHTS.KEY_READ:
        return 131097;
      case REG_RIGHTS.KEY_WRITE:
        return 131078;
    }
  }
}

class WindowsMonitorWindows implements WindowsMonitor {
  @override
  ui.Size getSize() {
    final Pointer<GUID> guidptr = calloc<GUID>();
    // I am way too dumb to do the bit shifting thing...
    // guidptr.ref
    // ..Data1 = 0x4d36e96e
    // ..Data2 = (0xe325 << 16) | (0x11 << 8) | 0xce
    // ..Data3 = (0xbf << 24) | (0xc1 << 16) | (0x08 << 8) | 0x00
    // ..Data4 = (0x2b << 24) | (0xe1 << 16) | (0x03 << 8) | 0x18;
    guidptr.ref.setGUID('{4d36e96e-e325-11ce-bfc1-08002be10318}');
    final int ptr = _SetupDiGetClassDevsW(guidptr, nullptr, 0, DIGCF.DIGCF_PRESENT);
    print(guidptr.ref);
    print(ptr);
    int width = 0;
    int height = 0;
    bool found = false;

    for (int i = 0; i < 5 && !found; ++i) {
      final Pointer<SP_DEVINFO_DATA> data = calloc<SP_DEVINFO_DATA>();
      // Since sizeOf fails here (it returns 40)
      // we need to set it to 32 bytes manually
      // for 32 bit machines it is 28 bytes.
      // skyleLogger?.d('SizeOf SP_DEVINFO_DATA: ${sizeOf<SP_DEVINFO_DATA>()}');
      data.ref.cbSize = 32;
      final int ret = SetupDiEnumDeviceInfo(ptr, i, data);
      if (ret == TRUE) {
        final int hDevRegKey = SetupDiOpenDevRegKey(ptr, data, DICS_FLAG.DICS_FLAG_GLOBAL.value, 0, DIREG.DIREG_DEV.value, REG_RIGHTS.KEY_READ.value);

        for (int j = 0, retValue = ERROR_SUCCESS; retValue != ERROR_NO_MORE_ITEMS && !found && j < 5; ++j) {
          const int nameSize = 128;
          final Pointer<Utf16> lpValueName = calloc<Uint16>(nameSize).cast<Utf16>();
          const int edidDataSize = 1024;

          final Pointer<Uint32> lpcchValueName = calloc<Uint32>()..value = nameSize;
          final Pointer<Uint32> lpType = calloc<Uint32>()..value = nameSize;
          final Pointer<Uint8> lpData = calloc<Uint8>(edidDataSize);
          final Pointer<Uint32> lpcbData = calloc<Uint32>()..value = edidDataSize;

          retValue = RegEnumValue(hDevRegKey, j, lpValueName, lpcchValueName, nullptr, lpType, lpData, lpcbData);

          if (retValue != ERROR_SUCCESS || lpValueName.toDartString() != 'EDID') continue;
          width = ((lpData[68] & 0xF0) << 4) + lpData[66];
          height = ((lpData[68] & 0x0F) << 8) + lpData[67];
          free(lpValueName);
          free(lpcchValueName);
          free(lpType);
          free(lpData);
          free(lpcbData);
          found = true;
          break;
        }
        RegCloseKey(hDevRegKey);
      }
      free(data);
      if (found) break;
    }
    SetupDiDestroyDeviceInfoList(ptr);
    free(guidptr);
    print('Got size from EDID: $width x $height.');
    return ui.Size(width.toDouble(), height.toDouble());
  }

  @override
  ui.Size getSizeBackup() {
    final hwnd = calloc<IntPtr>();
    final hdc = GetDC(hwnd.value);
    final width = GetDeviceCaps(hdc, 4);
    final height = GetDeviceCaps(hdc, 6);
    ReleaseDC(hwnd.value, hdc);
    free(hwnd);
    print('Got size from GetDeviceCaps: $width x $height.');
    return ui.Size(width.toDouble(), height.toDouble());
  }
}

WindowsMonitor getWindowsMonitor() => WindowsMonitorWindows();
