// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navLive => 'En directo';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navMovies => 'Películas';

  @override
  String get navSeries => 'Series';

  @override
  String get navSources => 'Fuentes';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navMore => 'Más';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get welcomeTitle => 'Bienvenido';

  @override
  String get welcomeBody =>
      'Añade una fuente para empezar: una cuenta Xtream Codes o una lista M3U. La app no incluye canales y todo se queda en este dispositivo.';

  @override
  String get addSource => 'Añadir una fuente';

  @override
  String get allSources => 'Todas las fuentes';

  @override
  String get allCategories => 'Todo';

  @override
  String get noCategoryName => 'Sin categoría';

  @override
  String get filterCategories => 'Filtrar categorías';

  @override
  String get emptyList => 'Nada que mostrar aquí.';

  @override
  String get emptyWhileImporting =>
      'Importación en curso, el catálogo aparecerá en cuanto esté listo.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString elementos',
      one: '1 elemento',
      zero: 'Ningún elemento',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Lista compacta';

  @override
  String get viewDetailed => 'Lista detallada';

  @override
  String get viewGrid => 'Cuadrícula';

  @override
  String get searchHint => 'Buscar';

  @override
  String noResults(String query) {
    return 'Sin resultados para «$query».';
  }

  @override
  String get sortLabel => 'Ordenar';

  @override
  String get sortSource => 'Orden de la fuente';

  @override
  String get sortNameAsc => 'Nombre (A → Z)';

  @override
  String get sortNameDesc => 'Nombre (Z → A)';

  @override
  String get sortRecent => 'Añadidos recientes';

  @override
  String get sortRating => 'Mejor valorados';

  @override
  String get filterLabel => 'Filtros';

  @override
  String get filterCountry => 'País o idioma';

  @override
  String get filterAllCountries => 'Todos los países';

  @override
  String get itemSource => 'Fuente';

  @override
  String get itemCategory => 'Categoría';

  @override
  String get itemCountry => 'País o idioma';

  @override
  String get itemFormat => 'Formato';

  @override
  String get itemRating => 'Valoración';

  @override
  String get favAdd => 'Añadir a favoritos';

  @override
  String get favRemove => 'Quitar de favoritos';

  @override
  String get favPickLists => 'Listas de favoritos';

  @override
  String get favNewList => 'Nueva lista';

  @override
  String get favDefaultName => 'Favoritos';

  @override
  String get favListName => 'Nombre de la lista';

  @override
  String get favListIcon => 'Icono';

  @override
  String get favRename => 'Editar lista';

  @override
  String get favDeleteList => 'Eliminar lista';

  @override
  String favDeleteConfirm(String name) {
    return '¿Eliminar la lista «$name»? Los canales siguen en el catálogo.';
  }

  @override
  String get favEmptyLists =>
      'Crea tus listas: deportes, noticias, niños… Un mismo canal puede estar en varias.';

  @override
  String get favEmptyList =>
      'Esta lista está vacía. Añade canales con la estrella.';

  @override
  String get favManage => 'Gestionar listas';

  @override
  String get favMoveUp => 'Subir';

  @override
  String get favMoveDown => 'Bajar';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED agrupa automáticamente los grupos de tus fuentes por país, región y tema. La pestaña En directo y tus listas no cambian.';

  @override
  String get filteredNoGroups =>
      'Aún no hay grupos que analizar. Actualiza una fuente.';

  @override
  String get filteredAnalyze => 'Organizar automáticamente';

  @override
  String get filteredManage => 'Organización';

  @override
  String get filteredReanalyze => 'Repetir el análisis y corregir';

  @override
  String get filteredRestore => 'Restaurar la organización automática';

  @override
  String get filteredRestoreConfirm =>
      'Se olvidarán tus correcciones manuales. Verás la vista previa antes de confirmar.';

  @override
  String get filteredPreviewTitle => 'Vista previa';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString grupos en $nodesString categorías';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Desde el último análisis: $added nuevos, $removed desaparecidos';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count grupos nuevos por ordenar: abrir la vista previa';
  }

  @override
  String filteredToCheck(int count) {
    return 'Por revisar ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Sin clasificar ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Grupos excluidos ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count grupos';
  }

  @override
  String get filteredValidate => 'Confirmar esta organización';

  @override
  String get filteredAccept => 'Está bien';

  @override
  String get filteredMove => 'Ordenar en…';

  @override
  String get filteredExclude => 'Excluir de la organización';

  @override
  String get filteredRestoreGroup => 'Reintegrar';

  @override
  String get filteredNewCategory => 'Nueva categoría';

  @override
  String get filteredRename => 'Renombrar';

  @override
  String get filteredMerge => 'Fusionar en…';

  @override
  String get sourcesTitle => 'Fuentes IPTV';

  @override
  String get refreshAll => 'Actualizar todo';

  @override
  String get refresh => 'Actualizar';

  @override
  String get editSource => 'Editar';

  @override
  String get deleteSource => 'Eliminar fuente';

  @override
  String deleteSourceConfirm(String name) {
    return '¿Eliminar «$name» y todo su catálogo de este dispositivo?';
  }

  @override
  String get sourceEnabled => 'Activada';

  @override
  String get makeDefault => 'Usar por defecto';

  @override
  String get isDefault => 'Fuente predeterminada';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Lista en línea';

  @override
  String get kindM3uFile => 'Archivo M3U';

  @override
  String countsLine(int live, int movies, int series) {
    final intl.NumberFormat liveNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String liveString = liveNumberFormat.format(live);
    final intl.NumberFormat moviesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String moviesString = moviesNumberFormat.format(movies);
    final intl.NumberFormat seriesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String seriesString = seriesNumberFormat.format(series);

    return '$liveString canales · $moviesString películas · $seriesString series';
  }

  @override
  String get neverRefreshed => 'Nunca actualizada';

  @override
  String refreshedAt(String date) {
    return 'Actualizada el $date';
  }

  @override
  String expiresAt(String date) {
    return 'Suscripción válida hasta $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reproducciones simultáneas',
      one: '1 reproducción simultánea',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Aplicar de todos modos';

  @override
  String reportDone(String name, int added, int updated, int missing) {
    final intl.NumberFormat addedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String addedString = addedNumberFormat.format(added);
    final intl.NumberFormat updatedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String updatedString = updatedNumberFormat.format(updated);
    final intl.NumberFormat missingNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String missingString = missingNumberFormat.format(missing);

    return '«$name»: $addedString añadidos, $updatedString cambiados, $missingString desaparecidos.';
  }

  @override
  String get stageConnecting => 'Conectando con el servidor…';

  @override
  String get stageLive => 'Descargando canales…';

  @override
  String get stageMovies => 'Descargando películas…';

  @override
  String get stageSeries => 'Descargando series…';

  @override
  String get stagePlaylist => 'Descargando la lista…';

  @override
  String get stageWriting => 'Guardando el catálogo…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Guardando: $countString elementos…';
  }

  @override
  String get stageQueued => 'En espera…';

  @override
  String get errorNetwork =>
      'Servidor inaccesible. Comprueba la dirección y tu conexión.';

  @override
  String get errorTimeout => 'El servidor tarda demasiado en responder.';

  @override
  String get errorCredentials =>
      'El servidor rechazó el usuario o la contraseña.';

  @override
  String get errorExpired => 'Esta suscripción ha caducado.';

  @override
  String get errorNotFound => 'Dirección no encontrada en este servidor.';

  @override
  String get errorNotPlaylist => 'Este contenido no es una lista M3U.';

  @override
  String get errorInvalidData => 'El servidor envió una respuesta ilegible.';

  @override
  String get errorEmpty =>
      'La fuente está vacía: se conserva el catálogo actual.';

  @override
  String errorSuspicious(String detail) {
    return 'Lista inusualmente reducida ($detail): se conserva el catálogo actual.';
  }

  @override
  String get errorFileMissing => 'Archivo no encontrado o ilegible.';

  @override
  String get errorUnknown =>
      'La actualización falló. Se conserva el catálogo actual.';

  @override
  String get formNewTitle => 'Nueva fuente';

  @override
  String get formEditTitle => 'Editar fuente';

  @override
  String get formName => 'Nombre';

  @override
  String get formNameHint => 'Ej.: Salón, Suscripción 1';

  @override
  String get formServer => 'Dirección del servidor';

  @override
  String get formUsername => 'Usuario';

  @override
  String get formPassword => 'Contraseña';

  @override
  String get formShowPassword => 'Mostrar contraseña';

  @override
  String get formPlaylistUrl => 'Dirección de la lista (M3U o M3U8)';

  @override
  String get formFile => 'Archivo de lista';

  @override
  String get formChooseFile => 'Elegir un archivo';

  @override
  String get formNoFile => 'Ningún archivo elegido';

  @override
  String get formFileUnavailable =>
      'No hay selector de archivos en este dispositivo.';

  @override
  String get formRequired => 'Campo obligatorio';

  @override
  String get formInvalidUrl => 'Dirección no válida';

  @override
  String get formContentTitle => 'Contenido a importar';

  @override
  String get formContentHint =>
      'El directo siempre se importa. Sin películas ni series, la carga es mucho más ligera.';

  @override
  String get formMovies => 'Películas';

  @override
  String get formSeries => 'Series';

  @override
  String get formContentRemoved =>
      'Los elementos ya importados y sus favoritos se quitarán de este dispositivo.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get settingsApp => 'Aplicación';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsPrivacy =>
      'Sin cuenta ni telemetría: tus fuentes y datos se quedan en este dispositivo.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: buscar · F5: actualizar todo · Ctrl+1 a 9: cambiar de pestaña';

  @override
  String get playerPlay => 'Reproducir';

  @override
  String get playerPause => 'Pausa';

  @override
  String get playerPrevious => 'Anterior';

  @override
  String get playerNext => 'Siguiente';

  @override
  String get playerRefresh => 'Actualizar la emisión';

  @override
  String get playerFullscreen => 'Pantalla completa';

  @override
  String get playerExitFullscreen => 'Salir de pantalla completa';

  @override
  String get playerMute => 'Silenciar';

  @override
  String get playerUnmute => 'Activar sonido';

  @override
  String get playerLive => 'EN DIRECTO';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'Reconectando… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Señal perdida…';

  @override
  String get playerFailedTitle => 'No se puede reproducir';

  @override
  String get playerFailedBody =>
      'Este flujo no responde. Puede que esté sin conexión o que tu suscripción ya se esté usando en otro dispositivo.';

  @override
  String get playerEndedTitle => 'Reproducción terminada';

  @override
  String get playerBackToList => 'Volver a la lista';

  @override
  String get externalTitle => 'Reproductor externo';

  @override
  String get externalOpen => 'Abrir en el reproductor externo';

  @override
  String get externalNone =>
      'No se encontró ningún reproductor. VLC se usa automáticamente si está instalado.';

  @override
  String get externalFailed =>
      'No se pudo iniciar el reproductor externo. Comprueba su ubicación en los ajustes.';

  @override
  String get externalDefault => 'Usar VLC';

  @override
  String get seriesFailed => 'No se pudieron cargar los episodios.';

  @override
  String get seriesEmpty => 'No hay episodios disponibles.';

  @override
  String seriesSeason(int number) {
    return 'Temporada $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Episodio $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count min';
  }

  @override
  String get navGuide => 'Guía';

  @override
  String get guideTitle => 'Guía de programación';

  @override
  String get guideScope => 'Canales mostrados';

  @override
  String get guideAllChannels => 'Todos los canales';

  @override
  String get guideNow => 'Ahora';

  @override
  String get guideToday => 'Hoy';

  @override
  String get guideYesterday => 'Ayer';

  @override
  String get guideTomorrow => 'Mañana';

  @override
  String get guideEarlier => '2 h antes';

  @override
  String get guideLater => '2 h después';

  @override
  String get guideEmptyTitle => 'Sin guía de programación';

  @override
  String get guideEmptyBody =>
      'Importe la guía de sus fuentes o añada una dirección o un archivo XMLTV en los ajustes.';

  @override
  String get guideImport => 'Importar la guía';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Importando la guía… $countString programas';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Guía actualizada: $programsString programas, $channelsString canales asociados.';
  }

  @override
  String guideFailed(String names) {
    return 'Guía no disponible: $names. Se conserva la anterior.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString programas · $date';
  }

  @override
  String get guideNeverRefreshed => 'Nunca actualizada';

  @override
  String get guideLastFailed => 'La última actualización falló.';

  @override
  String get guideRefresh => 'Actualizar la guía';

  @override
  String get guideAddUrl => 'Añadir una dirección';

  @override
  String get guideAddFile => 'Añadir un archivo';

  @override
  String get guideUrlHint => 'Dirección de la guía XMLTV';

  @override
  String get guideWatchLive => 'Ver en directo';

  @override
  String get guideReplay => 'Volver a ver';

  @override
  String get guideReplayOff => 'Repetición no disponible para este programa.';

  @override
  String get guideComing => 'Próximamente';

  @override
  String get guideChannel => 'Programación del canal';

  @override
  String get guideLink => 'Asociar a la guía';

  @override
  String get guideLinkHint => 'Nombre o identificador del canal';

  @override
  String get guideNoProgram => 'No hay programas para este canal.';

  @override
  String get guideNoChannels => 'Ningún canal de esta selección tiene guía.';

  @override
  String get backupTitle => 'Copia de seguridad';

  @override
  String get backupExport => 'Crear una copia';

  @override
  String get backupImport => 'Restaurar una copia';

  @override
  String get backupRestore => 'Restaurar';

  @override
  String get backupSecrets => 'Incluir las contraseñas';

  @override
  String get backupSecretsBody =>
      'El archivo se cifra entonces con su frase de contraseña. Si no, las contraseñas y las direcciones completas de las listas no se guardan.';

  @override
  String get backupPassphrase => 'Frase de contraseña';

  @override
  String get backupPassphraseAgain => 'Confirmar la frase';

  @override
  String get backupPassphraseShort => 'Al menos 8 caracteres.';

  @override
  String get backupPassphraseMismatch => 'Las dos frases no coinciden.';

  @override
  String get backupSaved => 'Copia guardada.';

  @override
  String get backupFailed => 'No se pudo escribir este archivo.';

  @override
  String get backupNotOurs => 'Este archivo no es una copia de Chud IPTV.';

  @override
  String get backupTooNew =>
      'Esta copia procede de una versión más reciente de la app.';

  @override
  String get backupDamaged => 'Esta copia está dañada.';

  @override
  String get backupWrongPassphrase => 'Frase incorrecta o archivo modificado.';

  @override
  String get backupConfirmTitle => '¿Restaurar esta copia?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Copia del $date. Fuentes: $sources, listas: $lists, favoritos: $favorites. Sus datos actuales se conservan y se completan; solo se sustituyen los ajustes.';
  }

  @override
  String get backupRestored => 'Restauración terminada.';

  @override
  String backupIncomplete(int count) {
    return 'Restauración terminada. Fuentes por completar: $count. Su contraseña o dirección no estaba en el archivo.';
  }

  @override
  String get autoTitle => 'Actualización automática';

  @override
  String get autoOff => 'Desactivada';

  @override
  String autoEvery(int hours) {
    return 'Cada $hours h';
  }

  @override
  String get dataTitle => 'Datos locales';

  @override
  String cacheLine(String size) {
    return 'Caché de logotipos: $size MB';
  }

  @override
  String get cacheClear => 'Vaciar la caché';

  @override
  String get cacheCleared => 'Caché vaciada.';

  @override
  String get wipeButton => 'Borrar todos los datos';

  @override
  String get wipeTitle => '¿Borrar todo?';

  @override
  String get wipeBody =>
      'Las fuentes, los favoritos, la guía, las descargas y los ajustes se eliminarán de este dispositivo. Esta acción es definitiva.';

  @override
  String get wipeConfirm => 'Borrar todo';

  @override
  String get updateTitle => 'Actualizaciones';

  @override
  String get updateAuto => 'Comprobar automáticamente';

  @override
  String get updateCheck => 'Buscar actualizaciones';

  @override
  String get updateChecking => 'Buscando…';

  @override
  String get updateLatest => 'Tiene la última versión.';

  @override
  String updateAvailable(String version) {
    return 'Versión $version disponible';
  }

  @override
  String get updateSee => 'Ver';

  @override
  String get updateInstall => 'Actualizar';

  @override
  String updateDownloading(int percent) {
    return 'Descargando… $percent %';
  }

  @override
  String get updateVerifying => 'Verificando el archivo…';

  @override
  String get updateRestarting => 'Instalando: la app se reiniciará.';

  @override
  String get updateConfirmSystem =>
      'Confirme la instalación en la ventana del sistema.';

  @override
  String get updateOpened =>
      'La descarga se abrió en su navegador: instálela y reinicie la app.';

  @override
  String get updateCancelled => 'Actualización cancelada.';

  @override
  String get updateNoChannel =>
      'Esta versión no está vinculada a ningún canal de actualización.';

  @override
  String get updateFailedNetwork =>
      'No se pudo contactar con el servidor de actualización.';

  @override
  String get updateFailedSignature =>
      'Firma no válida: actualización rechazada.';

  @override
  String get updateFailedIntegrity => 'Archivo dañado: no se instaló nada.';

  @override
  String get updateFailedInstall => 'La instalación falló.';

  @override
  String updateDone(String version) {
    return 'Actualización a la versión $version instalada.';
  }

  @override
  String updateNotApplied(String version) {
    return 'La actualización a la versión $version no se pudo instalar: se mantiene la versión anterior.';
  }

  @override
  String get navDownloads => 'Descargas';

  @override
  String get downloadAction => 'Descargar';

  @override
  String get downloadSeason => 'Descargar la temporada';

  @override
  String downloadAdded(String title) {
    return 'Añadido a descargas: $title';
  }

  @override
  String get downloadPlay => 'Reproducir el archivo';

  @override
  String get downloadEmptyTitle => 'Sin descargas';

  @override
  String get downloadEmptyBody =>
      'Descargue una película desde su ficha, o un episodio desde su serie, para verlo sin conexión.';

  @override
  String get downloadQueued => 'En espera';

  @override
  String get downloadPaused => 'En pausa';

  @override
  String get downloadHeld => 'Esperando a que termine la reproducción';

  @override
  String get downloadPause => 'Pausar';

  @override
  String get downloadResume => 'Reanudar';

  @override
  String get downloadDeleteTitle => '¿Eliminar esta descarga?';

  @override
  String downloadDeleteBody(String title) {
    return '$title se eliminará de este dispositivo.';
  }

  @override
  String get downloadFolder => 'Carpeta de descargas';

  @override
  String downloadSizeMb(String size) {
    return '$size MB';
  }

  @override
  String downloadSizeGb(String size) {
    return '$size GB';
  }

  @override
  String get downloadErrorNetwork =>
      'Conexión perdida. El archivo se conserva: se reanudará donde se detuvo.';

  @override
  String get downloadErrorServer =>
      'El servidor lo rechazó. Quizá otra reproducción esté usando su conexión.';

  @override
  String get downloadErrorFormat =>
      'Este contenido se emite por segmentos y no se puede descargar.';

  @override
  String get downloadErrorDisk =>
      'No se pudo escribir: espacio insuficiente o carpeta inaccesible.';

  @override
  String get downloadErrorSource => 'La fuente de esta descarga ya no existe.';

  @override
  String get downloadErrorMissing => 'El archivo se movió o eliminó.';

  @override
  String get downloadFolderChoose => 'Elegir una carpeta';

  @override
  String get downloadFolderReset => 'Carpeta predeterminada';

  @override
  String get downloadFolderApp => 'Carpeta de la app, se elimina con ella';

  @override
  String get downloadFolderHint =>
      'Se aplica a las próximas descargas. Las terminadas se quedan donde están.';

  @override
  String get favChooseBody =>
      'Aún no tiene ninguna lista. ¿Dónde quiere guardar este favorito?';

  @override
  String get favGlobal => 'Favoritos generales';

  @override
  String get settingsPhoneTitle => 'Reproducción en el teléfono';

  @override
  String get settingsPip => 'Imagen en imagen';

  @override
  String get settingsPipBody =>
      'El vídeo sigue en una ventana pequeña al salir de la app. Aparece un botón en el reproductor.';

  @override
  String get settingsRadio => 'Modo radio';

  @override
  String get settingsRadioBody =>
      'El sonido continúa con el teléfono bloqueado o la app en segundo plano. Aparece un botón en el reproductor.';

  @override
  String get playerPipOn => 'Imagen en imagen activada';

  @override
  String get playerPipOff => 'Imagen en imagen desactivada';

  @override
  String get playerRadioOn => 'Modo radio activado';

  @override
  String get playerRadioOff => 'Modo radio desactivado';

  @override
  String get radioNotificationStop => 'Detener';
}
