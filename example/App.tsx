import React, { useState } from 'react';
import {
  ActivityIndicator,
  SafeAreaView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { requestCameraPermission, startLiveness } from 'react-native-amplify-liveness';

function App(): React.JSX.Element {
  const [result, setResult] = useState('No result yet');
  const [running, setRunning] = useState(false);
  const [credentialsState, setCredentialsState] = useState<'idle' | 'fetching' | 'fetched'>(
    'idle',
  );

  const runLiveness = async () => {
    const region = 'us-east-1';

    setRunning(true);
    setCredentialsState('idle');
    try {
      const hasCamera = await requestCameraPermission();
      if (!hasCamera) {
        setResult('Camera permission was denied.');
        return;
      }

      const sessionResponse = await fetch(
        'fetch session id',
        { method: 'POST' },
      );
      const sessionPayload = await sessionResponse.json();
      if (!sessionResponse.ok || !sessionPayload?.success || !sessionPayload?.data?.sessionId) {
        throw new Error('Failed to create liveness session.');
      }
      const sessionId: string = sessionPayload.data.sessionId;

      setCredentialsState('fetching');
      const credentialsResponse = await fetch(
        'fetch credentials'
      );
      const credentialsPayload = await credentialsResponse.json();

      if (!credentialsResponse.ok || !credentialsPayload?.success || !credentialsPayload?.data) {
        throw new Error('Failed to fetch liveness credentials.');
      }

      const { accessKeyId, secretAccessKey, sessionToken } = credentialsPayload.data;
      if (!accessKeyId || !secretAccessKey || !sessionToken) {
        throw new Error('Credentials response is missing required fields.');
      }
      setCredentialsState('fetched');
      setResult('Session created and credentials fetched. Starting liveness...');

      const response = await startLiveness({
        sessionId,
        region,
        accessKeyId,
        secretAccessKey,
        sessionToken
      });
      setResult(JSON.stringify(response, null, 2));
    } catch (error) {
      setCredentialsState('idle');
      const message = error instanceof Error ? error.message : 'Unknown error';
      setResult(`Error: ${message}`);
    } finally {
      setRunning(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.title}>Amplify Liveness Example</Text>
      <Text style={styles.caption}>
        Set `sessionId` and `region` inside `runLiveness()` before running.
      </Text>

      <TouchableOpacity
        style={[styles.button, running && styles.buttonDisabled]}
        onPress={runLiveness}
        disabled={running}>
        <View style={styles.buttonContent}>
          {credentialsState === 'fetching' ? (
            <ActivityIndicator size="small" color="#fff" style={styles.buttonSpinner} />
          ) : null}
          <Text style={styles.buttonText}>
            {credentialsState === 'fetching'
              ? 'Fetching Credentials...'
              : running
                ? 'Starting Liveness...'
                : 'Start Liveness'}
          </Text>
        </View>
      </TouchableOpacity>
      {credentialsState === 'fetched' ? (
        <Text style={styles.statusText}>Credentials fetched successfully.</Text>
      ) : null}

      <View style={styles.resultBox}>
        <Text style={styles.resultText}>{result}</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, backgroundColor: '#fff' },
  title: { fontSize: 22, fontWeight: '700', marginBottom: 12 },
  caption: { marginBottom: 10, color: '#444' },
  button: {
    backgroundColor: '#2563eb',
    borderRadius: 8,
    paddingVertical: 12,
    alignItems: 'center',
  },
  buttonContent: { flexDirection: 'row', alignItems: 'center' },
  buttonSpinner: { marginRight: 8 },
  buttonDisabled: { opacity: 0.5 },
  buttonText: { color: '#fff', fontWeight: '700' },
  statusText: { marginTop: 8, color: '#166534', fontWeight: '600' },
  resultBox: {
    marginTop: 14,
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 10,
  },
  resultText: { fontFamily: 'Courier', fontSize: 12 },
});

export default App;
