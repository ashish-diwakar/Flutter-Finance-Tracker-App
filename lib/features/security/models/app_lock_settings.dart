class AppLockSettings {

  final bool enabled;

  final bool lockOnResume;

  final bool useDeviceCredentials;

  final Duration autoLockTimeout;

  const AppLockSettings({

    this.enabled = true,

    this.lockOnResume = true,

    this.useDeviceCredentials = true,

    this.autoLockTimeout =
        const Duration(minutes: 1),
  });

  AppLockSettings copyWith({

    bool? enabled,

    bool? lockOnResume,

    bool? useDeviceCredentials,

    Duration? autoLockTimeout,
  }) {

    return AppLockSettings(

      enabled:
          enabled ?? this.enabled,

      lockOnResume:
          lockOnResume ??
              this.lockOnResume,

      useDeviceCredentials:
          useDeviceCredentials ??
              this.useDeviceCredentials,

      autoLockTimeout:
          autoLockTimeout ??
              this.autoLockTimeout,
    );
  }
}