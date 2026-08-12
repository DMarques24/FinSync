import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Avisos locais, agendados pelo próprio telemóvel.
///
/// Não há servidor de push nem custos associados: a app calcula as datas e
/// entrega-as ao sistema operativo, que se encarrega de as mostrar mesmo
/// com a app fechada. Em troca, cabe-nos reagendar tudo sempre que a app
/// abre — é o que o `NotificationScheduler` faz.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Cada família de avisos tem o seu intervalo de ids, para se poder
  /// cancelar um tipo sem apagar os outros. Um evento com id 7 fica no
  /// aviso 2007; um objetivo com id 7 fica no 3007.
  static const _dailyLogId = 1000;
  static const _overspendId = 1001;
  static const _eventBase = 2000;
  static const _goalSavingBase = 3000;
  static const _goalDoneBase = 4000;

  static const _channelId = 'finsync_reminders';

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    // As permissões não são pedidas no arranque de propósito: pedir antes
    // de a pessoa perceber para que servem é a melhor forma de levar com
    // um "não". São pedidas quando ela liga o primeiro aviso.
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );

    _initialized = true;
  }

  /// Pede autorização. Devolve `false` se a pessoa recusar — nesse caso os
  /// agendamentos seguintes não fazem nada, mas também não rebentam.
  static Future<bool> requestPermission() async {
    await initialize();

    if (Platform.isIOS) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      return granted ?? false;
    }

    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final granted = await android?.requestNotificationsPermission();

      // A partir do Android 12 é preciso uma segunda autorização para
      // agendar com hora exata. Sem ela o sistema entrega quando lhe der
      // jeito, o que para um lembrete diário até chega.
      await android?.requestExactAlarmsPermission();

      return granted ?? false;
    }

    return false;
  }

  static NotificationDetails get _details {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        'Lembretes',
        channelDescription: 'Avisos sobre objetivos, eventos e despesas.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  /// Agenda para um instante concreto. Datas no passado são ignoradas —
  /// o sistema entregaria o aviso de imediato, o que assusta mais do que
  /// informa.
  static Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    await initialize();

    if (!when.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // `TZDateTime.from` preserva o instante. Como as datas são sempre
      // construídas na hora do telemóvel, o aviso sai à hora certa sem
      // precisarmos de saber o nome do fuso horário.
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  // ── Ids por família ────────────────────────────────────────────────

  static int dailyLogId(int dayOffset) => _dailyLogId + dayOffset * 10;
  static int overspendId() => _overspendId;
  static int eventId(int calendarEventId) => _eventBase + calendarEventId;
  static int goalSavingId(int desireId) => _goalSavingBase + desireId;
  static int goalDoneId(int desireId) => _goalDoneBase + desireId;

  static Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id: id);
  }

  /// Cancela tudo o que estiver agendado. Chamado antes de reagendar, para
  /// não acumular avisos de eventos que entretanto foram apagados.
  static Future<void> cancelAllScheduled() async {
    await initialize();

    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      // Os avisos de objetivo concluído são mostrados na hora, não
      // agendados, por isso não aparecem aqui — mas a verificação evita
      // apagar qualquer coisa que venhamos a agendar nessa gama.
      if (request.id >= _goalDoneBase) continue;
      await _plugin.cancel(id: request.id);
    }
  }
}
