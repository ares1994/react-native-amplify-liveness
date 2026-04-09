import { NativeModules, PermissionsAndroid, Platform } from 'react-native';

export type StartLivenessInput = {
  sessionId: string;
  region: string;
  accessKeyId: string;
  secretAccessKey: string;
  sessionToken: string;
  expirationEpochSeconds?: number;
};

export type LivenessResult = {
  sessionId: string;
  status: 'completed' | 'error' | 'cancelled';
  errorMessage?: string;
};

type NativeAmplifyLivenessModule = {
  startLiveness(input: StartLivenessInput): Promise<LivenessResult>;
};

const LINKING_ERROR =
  `The package 'react-native-amplify-liveness' does not appear to be linked.\n` +
  Platform.select({ ios: "- Run 'pod install'\n", default: '' }) +
  '- Rebuild the app after installing\n';

const AmplifyLivenessModule: NativeAmplifyLivenessModule = NativeModules.AmplifyLiveness
  ? (NativeModules.AmplifyLiveness as NativeAmplifyLivenessModule)
  : (new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        }
      }
    ) as NativeAmplifyLivenessModule);

export async function requestCameraPermission(): Promise<boolean> {
  if (Platform.OS === 'android') {
    const result = await PermissionsAndroid.request(PermissionsAndroid.PERMISSIONS.CAMERA);
    return result === PermissionsAndroid.RESULTS.GRANTED;
  }

  // iOS permission prompt is handled by native liveness UI.
  return true;
}

export function startLiveness(input: StartLivenessInput): Promise<LivenessResult> {
  const expirationEpochSeconds =
    input.expirationEpochSeconds ?? Math.floor(Date.now() / 1000) + 5 * 60;

  return AmplifyLivenessModule.startLiveness({
    ...input,
    expirationEpochSeconds
  });
}

export default {
  startLiveness,
  requestCameraPermission
};
