
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'active_codec.dart';
import 'asset_player.dart';
import 'drop_downs.dart';
import 'recorder_controls.dart';
import 'recorder_state.dart';
import 'recording_player.dart';
import 'remote_player.dart';
import 'track_switched.dart';
import 'util/log.dart';

///
class MainBody extends StatefulWidget {
  ///
  const MainBody({
    Key key,
  }) : super(key: key);

  @override
  _MainBodyState createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  bool _useOSUI = false;

  bool initialised = false;

  Future<bool> init() async {
    if (!initialised) {
      await initializeDateFormatting();
      await RecorderState().init();
      ActiveCodec().recorderModule = RecorderState().recorderModule;
      await ActiveCodec().setCodec(_useOSUI, Codec.aacADTS);

      initialised = true;
    }
    return initialised;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        initialData: false,
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return Container(
              width: 0,
              height: 0,
              color: Colors.white,
            );
          } else {
            final dropdowns = Dropdowns(
                onCodecChanged: (codec) =>
                    ActiveCodec().setCodec(_useOSUI, codec));
            final trackSwitch = TrackSwitch(
              isAudioPlayer: _useOSUI,
              switchPlayer: (allow) => switchPlayer(useOSUI: allow),
            );

            Widget recorderControls = RecorderControls();

            return ListView(
              children: <Widget>[
                recorderControls,
                dropdowns,
                buildPlayBars(),
                trackSwitch,
              ],
            );
          }
        });
  }

  void switchPlayer({bool useOSUI}) async {
    try {
      _useOSUI = useOSUI;
      await _switchModes(useOSUI);
      setState(() {});
    } on Object catch (err) {
      Log.d(err.toString());
      rethrow;
    }
  }

  /// Allows us to switch the player module
  Future<void> _switchModes(bool useTracks) async {
    RecorderState().reset();
  }

  Widget buildPlayBars() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Left("Recording Playback"),
            RecordingPlayer(),
            Left("Asset Playback"),
            AssetPlayer(),
            Left("Remote Track Playback"),
            RemotePlayer(),
          ],
        ));
  }
}

class Left extends StatelessWidget {
  final String label;

  Left(this.label);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4, left: 8),
      child: Container(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
