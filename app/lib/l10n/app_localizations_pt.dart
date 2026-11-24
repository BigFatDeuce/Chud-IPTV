// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get navLive => 'Ao vivo';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navMovies => 'Filmes';

  @override
  String get navSeries => 'Séries';

  @override
  String get navSources => 'Fontes';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get navMore => 'Mais';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get welcomeTitle => 'Bem-vindo';

  @override
  String get welcomeBody =>
      'Adicione uma fonte para começar: uma conta Xtream Codes ou uma lista M3U. A app não fornece canais e tudo fica neste dispositivo.';

  @override
  String get addSource => 'Adicionar uma fonte';

  @override
  String get allSources => 'Todas as fontes';

  @override
  String get allCategories => 'Tudo';

  @override
  String get noCategoryName => 'Sem categoria';

  @override
  String get filterCategories => 'Filtrar categorias';

  @override
  String get emptyList => 'Nada para mostrar aqui.';

  @override
  String get emptyWhileImporting =>
      'Importação em curso, o catálogo aparecerá assim que estiver pronto.';

  @override
  String itemCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String get viewCompact => 'Lista compacta';

  @override
  String get viewDetailed => 'Lista detalhada';

  @override
  String get viewGrid => 'Grelha';

  @override
  String get searchHint => 'Pesquisar';

  @override
  String noResults(String query) {
    return 'Sem resultados para «$query».';
  }

  @override
  String get sortLabel => 'Ordenar';

  @override
  String get sortSource => 'Ordem da fonte';

  @override
  String get sortNameAsc => 'Nome (A → Z)';

  @override
  String get sortNameDesc => 'Nome (Z → A)';

  @override
  String get sortRecent => 'Adicionados recentemente';

  @override
  String get sortRating => 'Mais bem avaliados';

  @override
  String get filterLabel => 'Filtros';

  @override
  String get filterCountry => 'País ou idioma';

  @override
  String get filterAllCountries => 'Todos os países';

  @override
  String get itemSource => 'Fonte';

  @override
  String get itemCategory => 'Categoria';

  @override
  String get itemCountry => 'País ou idioma';

  @override
  String get itemFormat => 'Formato';

  @override
  String get itemRating => 'Avaliação';

  @override
  String get favAdd => 'Adicionar aos favoritos';

  @override
  String get favRemove => 'Remover dos favoritos';

  @override
  String get favPickLists => 'Listas de favoritos';

  @override
  String get favNewList => 'Nova lista';

  @override
  String get favDefaultName => 'Favoritos';

  @override
  String get favListName => 'Nome da lista';

  @override
  String get favListIcon => 'Ícone';

  @override
  String get favRename => 'Editar lista';

  @override
  String get favDeleteList => 'Eliminar lista';

  @override
  String favDeleteConfirm(String name) {
    return 'Eliminar a lista «$name»? Os canais permanecem no catálogo.';
  }

  @override
  String get favEmptyLists =>
      'Crie as suas listas: desporto, notícias, crianças… O mesmo canal pode estar em várias.';

  @override
  String get favEmptyList =>
      'Esta lista está vazia. Adicione canais com a estrela.';

  @override
  String get favManage => 'Gerir listas';

  @override
  String get favMoveUp => 'Subir';

  @override
  String get favMoveDown => 'Descer';

  @override
  String favListLine(String name, int count) {
    return '$name ($count)';
  }

  @override
  String get filteredIntro =>
      'FILTERED agrupa automaticamente os grupos das suas fontes por país, região e tema. O separador Ao vivo e as suas listas não mudam.';

  @override
  String get filteredNoGroups =>
      'Ainda não há grupos para analisar. Atualize uma fonte.';

  @override
  String get filteredAnalyze => 'Organizar automaticamente';

  @override
  String get filteredManage => 'Organização';

  @override
  String get filteredReanalyze => 'Repetir a análise e corrigir';

  @override
  String get filteredRestore => 'Restaurar a organização automática';

  @override
  String get filteredRestoreConfirm =>
      'As suas correções manuais serão esquecidas. Verá a pré-visualização antes de confirmar.';

  @override
  String get filteredPreviewTitle => 'Pré-visualização';

  @override
  String filteredSummary(int groups, int nodes) {
    final intl.NumberFormat groupsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String groupsString = groupsNumberFormat.format(groups);
    final intl.NumberFormat nodesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String nodesString = nodesNumberFormat.format(nodes);

    return '$groupsString grupos em $nodesString categorias';
  }

  @override
  String filteredDelta(int added, int removed) {
    return 'Desde a última análise: $added novos, $removed desaparecidos';
  }

  @override
  String filteredNewGroups(int count) {
    return '$count grupos novos por organizar: abrir a pré-visualização';
  }

  @override
  String filteredToCheck(int count) {
    return 'A verificar ($count)';
  }

  @override
  String filteredUnclassified(int count) {
    return 'Não classificados ($count)';
  }

  @override
  String filteredExcluded(int count) {
    return 'Grupos excluídos ($count)';
  }

  @override
  String filteredGroupsCount(int count) {
    return '$count grupos';
  }

  @override
  String get filteredValidate => 'Confirmar esta organização';

  @override
  String get filteredAccept => 'Está certo';

  @override
  String get filteredMove => 'Colocar em…';

  @override
  String get filteredExclude => 'Excluir da organização';

  @override
  String get filteredRestoreGroup => 'Reintegrar';

  @override
  String get filteredNewCategory => 'Nova categoria';

  @override
  String get filteredRename => 'Renomear';

  @override
  String get filteredMerge => 'Fundir em…';

  @override
  String get sourcesTitle => 'Fontes IPTV';

  @override
  String get refreshAll => 'Atualizar tudo';

  @override
  String get refresh => 'Atualizar';

  @override
  String get editSource => 'Editar';

  @override
  String get deleteSource => 'Eliminar fonte';

  @override
  String deleteSourceConfirm(String name) {
    return 'Eliminar «$name» e todo o seu catálogo deste dispositivo?';
  }

  @override
  String get sourceEnabled => 'Ativada';

  @override
  String get makeDefault => 'Usar por predefinição';

  @override
  String get isDefault => 'Fonte predefinida';

  @override
  String get kindXtream => 'Xtream Codes';

  @override
  String get kindM3uUrl => 'Lista online';

  @override
  String get kindM3uFile => 'Ficheiro M3U';

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

    return '$liveString canais · $moviesString filmes · $seriesString séries';
  }

  @override
  String get neverRefreshed => 'Nunca atualizada';

  @override
  String refreshedAt(String date) {
    return 'Atualizada em $date';
  }

  @override
  String expiresAt(String date) {
    return 'Subscrição válida até $date';
  }

  @override
  String maxConnections(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reproduções simultâneas',
      one: '1 reprodução simultânea',
    );
    return '$_temp0';
  }

  @override
  String get applyAnyway => 'Aplicar mesmo assim';

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

    return '«$name»: $addedString adicionados, $updatedString alterados, $missingString desaparecidos.';
  }

  @override
  String get stageConnecting => 'A ligar ao servidor…';

  @override
  String get stageLive => 'A transferir canais…';

  @override
  String get stageMovies => 'A transferir filmes…';

  @override
  String get stageSeries => 'A transferir séries…';

  @override
  String get stagePlaylist => 'A transferir a lista…';

  @override
  String get stageWriting => 'A guardar o catálogo…';

  @override
  String stageWritingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'A guardar: $countString itens…';
  }

  @override
  String get stageQueued => 'Em espera…';

  @override
  String get errorNetwork =>
      'Servidor inacessível. Verifique o endereço e a ligação.';

  @override
  String get errorTimeout => 'O servidor está a demorar demasiado a responder.';

  @override
  String get errorCredentials =>
      'O servidor recusou o utilizador ou a palavra-passe.';

  @override
  String get errorExpired => 'Esta subscrição expirou.';

  @override
  String get errorNotFound => 'Endereço não encontrado neste servidor.';

  @override
  String get errorNotPlaylist => 'Este conteúdo não é uma lista M3U.';

  @override
  String get errorInvalidData => 'O servidor enviou uma resposta ilegível.';

  @override
  String get errorEmpty => 'A fonte está vazia: o catálogo atual é mantido.';

  @override
  String errorSuspicious(String detail) {
    return 'Lista anormalmente reduzida ($detail): o catálogo atual é mantido.';
  }

  @override
  String get errorFileMissing => 'Ficheiro não encontrado ou ilegível.';

  @override
  String get errorUnknown =>
      'A atualização falhou. O catálogo atual é mantido.';

  @override
  String get formNewTitle => 'Nova fonte';

  @override
  String get formEditTitle => 'Editar fonte';

  @override
  String get formName => 'Nome';

  @override
  String get formNameHint => 'Ex.: Sala, Subscrição 1';

  @override
  String get formServer => 'Endereço do servidor';

  @override
  String get formUsername => 'Utilizador';

  @override
  String get formPassword => 'Palavra-passe';

  @override
  String get formShowPassword => 'Mostrar palavra-passe';

  @override
  String get formPlaylistUrl => 'Endereço da lista (M3U ou M3U8)';

  @override
  String get formFile => 'Ficheiro da lista';

  @override
  String get formChooseFile => 'Escolher um ficheiro';

  @override
  String get formNoFile => 'Nenhum ficheiro escolhido';

  @override
  String get formFileUnavailable =>
      'Não há seletor de ficheiros neste dispositivo.';

  @override
  String get formRequired => 'Campo obrigatório';

  @override
  String get formInvalidUrl => 'Endereço inválido';

  @override
  String get formContentTitle => 'Conteúdo a importar';

  @override
  String get formContentHint =>
      'O ao vivo é sempre importado. Sem filmes nem séries, o carregamento é muito mais leve.';

  @override
  String get formMovies => 'Filmes';

  @override
  String get formSeries => 'Séries';

  @override
  String get formContentRemoved =>
      'Os itens já importados e os seus favoritos serão removidos deste dispositivo.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get settingsApp => 'Aplicação';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsPrivacy =>
      'Sem conta nem telemetria: as suas fontes e dados ficam neste dispositivo.';

  @override
  String get settingsShortcuts =>
      'Ctrl+F: pesquisar · F5: atualizar tudo · Ctrl+1 a 9: mudar de separador';

  @override
  String get playerPlay => 'Reproduzir';

  @override
  String get playerPause => 'Pausa';

  @override
  String get playerPrevious => 'Anterior';

  @override
  String get playerNext => 'Seguinte';

  @override
  String get playerRefresh => 'Atualizar a transmissão';

  @override
  String get playerFullscreen => 'Ecrã inteiro';

  @override
  String get playerExitFullscreen => 'Sair do ecrã inteiro';

  @override
  String get playerMute => 'Silenciar';

  @override
  String get playerUnmute => 'Ativar som';

  @override
  String get playerLive => 'AO VIVO';

  @override
  String playerReconnecting(int attempt, int total) {
    return 'A religar… ($attempt/$total)';
  }

  @override
  String get playerSignalLost => 'Sinal perdido…';

  @override
  String get playerFailedTitle => 'Não é possível reproduzir';

  @override
  String get playerFailedBody =>
      'Esta transmissão não responde. Pode estar offline ou a sua subscrição já está em uso noutro dispositivo.';

  @override
  String get playerEndedTitle => 'Reprodução terminada';

  @override
  String get playerBackToList => 'Voltar à lista';

  @override
  String get externalTitle => 'Leitor externo';

  @override
  String get externalOpen => 'Abrir no leitor externo';

  @override
  String get externalNone =>
      'Nenhum leitor encontrado. O VLC é usado automaticamente se estiver instalado.';

  @override
  String get externalFailed =>
      'Não foi possível iniciar o leitor externo. Verifique a localização nos ajustes.';

  @override
  String get externalDefault => 'Usar o VLC';

  @override
  String get seriesFailed => 'Não foi possível carregar os episódios.';

  @override
  String get seriesEmpty => 'Sem episódios disponíveis.';

  @override
  String seriesSeason(int number) {
    return 'Temporada $number';
  }

  @override
  String seriesEpisode(int number) {
    return 'Episódio $number';
  }

  @override
  String seriesMinutes(int count) {
    return '$count min';
  }

  @override
  String get navGuide => 'Guia';

  @override
  String get guideTitle => 'Guia de programação';

  @override
  String get guideScope => 'Canais apresentados';

  @override
  String get guideAllChannels => 'Todos os canais';

  @override
  String get guideNow => 'Agora';

  @override
  String get guideToday => 'Hoje';

  @override
  String get guideYesterday => 'Ontem';

  @override
  String get guideTomorrow => 'Amanhã';

  @override
  String get guideEarlier => '2 h antes';

  @override
  String get guideLater => '2 h depois';

  @override
  String get guideEmptyTitle => 'Sem guia de programação';

  @override
  String get guideEmptyBody =>
      'Importe o guia das suas fontes ou adicione um endereço ou ficheiro XMLTV nos ajustes.';

  @override
  String get guideImport => 'Importar o guia';

  @override
  String guideImporting(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'A importar o guia… $countString programas';
  }

  @override
  String guideDone(int programs, int channels) {
    final intl.NumberFormat programsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String programsString = programsNumberFormat.format(programs);
    final intl.NumberFormat channelsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String channelsString = channelsNumberFormat.format(channels);

    return 'Guia atualizado: $programsString programas, $channelsString canais associados.';
  }

  @override
  String guideFailed(String names) {
    return 'Guia indisponível: $names. O anterior é mantido.';
  }

  @override
  String guideSourceLine(int count, String date) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString programas · $date';
  }

  @override
  String get guideNeverRefreshed => 'Nunca atualizado';

  @override
  String get guideLastFailed => 'A última atualização falhou.';

  @override
  String get guideRefresh => 'Atualizar o guia';

  @override
  String get guideAddUrl => 'Adicionar um endereço';

  @override
  String get guideAddFile => 'Adicionar um ficheiro';

  @override
  String get guideUrlHint => 'Endereço do guia XMLTV';

  @override
  String get guideWatchLive => 'Ver em direto';

  @override
  String get guideReplay => 'Rever';

  @override
  String get guideReplayOff => 'Repetição indisponível para este programa.';

  @override
  String get guideComing => 'Em breve';

  @override
  String get guideChannel => 'Programação do canal';

  @override
  String get guideLink => 'Associar ao guia';

  @override
  String get guideLinkHint => 'Nome ou identificador do canal';

  @override
  String get guideNoProgram => 'Sem programas para este canal.';

  @override
  String get guideNoChannels => 'Nenhum canal desta seleção tem guia.';

  @override
  String get backupTitle => 'Cópia de segurança';

  @override
  String get backupExport => 'Criar uma cópia';

  @override
  String get backupImport => 'Restaurar uma cópia';

  @override
  String get backupRestore => 'Restaurar';

  @override
  String get backupSecrets => 'Incluir as palavras-passe';

  @override
  String get backupSecretsBody =>
      'O ficheiro é então cifrado com a sua frase de acesso. Caso contrário, as palavras-passe e os endereços completos das listas não são guardados.';

  @override
  String get backupPassphrase => 'Frase de acesso';

  @override
  String get backupPassphraseAgain => 'Confirmar a frase';

  @override
  String get backupPassphraseShort => 'Pelo menos 8 caracteres.';

  @override
  String get backupPassphraseMismatch => 'As duas frases são diferentes.';

  @override
  String get backupSaved => 'Cópia guardada.';

  @override
  String get backupFailed => 'Não foi possível escrever este ficheiro.';

  @override
  String get backupNotOurs => 'Este ficheiro não é uma cópia do Chud IPTV.';

  @override
  String get backupTooNew =>
      'Esta cópia vem de uma versão mais recente da app.';

  @override
  String get backupDamaged => 'Esta cópia está danificada.';

  @override
  String get backupWrongPassphrase => 'Frase incorreta ou ficheiro alterado.';

  @override
  String get backupConfirmTitle => 'Restaurar esta cópia?';

  @override
  String backupConfirmBody(String date, int sources, int lists, int favorites) {
    return 'Cópia de $date. Fontes: $sources, listas: $lists, favoritos: $favorites. Os seus dados atuais são mantidos e completados; apenas os ajustes são substituídos.';
  }

  @override
  String get backupRestored => 'Restauro concluído.';

  @override
  String backupIncomplete(int count) {
    return 'Restauro concluído. Fontes por completar: $count. A palavra-passe ou o endereço não estava no ficheiro.';
  }

  @override
  String get autoTitle => 'Atualização automática';

  @override
  String get autoOff => 'Desativada';

  @override
  String autoEvery(int hours) {
    return 'A cada $hours h';
  }

  @override
  String get dataTitle => 'Dados locais';

  @override
  String cacheLine(String size) {
    return 'Cache de logótipos: $size MB';
  }

  @override
  String get cacheClear => 'Limpar a cache';

  @override
  String get cacheCleared => 'Cache limpa.';

  @override
  String get wipeButton => 'Apagar todos os dados';

  @override
  String get wipeTitle => 'Apagar tudo?';

  @override
  String get wipeBody =>
      'As fontes, os favoritos, o guia, as transferências e os ajustes serão removidos deste dispositivo. Esta ação é definitiva.';

  @override
  String get wipeConfirm => 'Apagar tudo';

  @override
  String get updateTitle => 'Atualizações';

  @override
  String get updateAuto => 'Verificar automaticamente';

  @override
  String get updateCheck => 'Procurar atualizações';

  @override
  String get updateChecking => 'A procurar…';

  @override
  String get updateLatest => 'Tem a versão mais recente.';

  @override
  String updateAvailable(String version) {
    return 'Versão $version disponível';
  }

  @override
  String get updateSee => 'Ver';

  @override
  String get updateInstall => 'Atualizar';

  @override
  String updateDownloading(int percent) {
    return 'A transferir… $percent %';
  }

  @override
  String get updateVerifying => 'A verificar o ficheiro…';

  @override
  String get updateRestarting => 'A instalar: a app vai reiniciar.';

  @override
  String get updateConfirmSystem =>
      'Confirme a instalação na janela do sistema.';

  @override
  String get updateOpened =>
      'A transferência abriu no navegador: instale-a e reinicie a app.';

  @override
  String get updateCancelled => 'Atualização cancelada.';

  @override
  String get updateNoChannel =>
      'Esta versão não está ligada a nenhum canal de atualização.';

  @override
  String get updateFailedNetwork =>
      'Não foi possível contactar o servidor de atualização.';

  @override
  String get updateFailedSignature =>
      'Assinatura inválida: atualização recusada.';

  @override
  String get updateFailedIntegrity =>
      'Ficheiro danificado: nada foi instalado.';

  @override
  String get updateFailedInstall => 'A instalação falhou.';

  @override
  String updateDone(String version) {
    return 'Atualização para a versão $version instalada.';
  }

  @override
  String updateNotApplied(String version) {
    return 'A atualização para a versão $version não pôde ser instalada: a versão anterior mantém-se.';
  }

  @override
  String get navDownloads => 'Transferências';

  @override
  String get downloadAction => 'Transferir';

  @override
  String get downloadSeason => 'Transferir a temporada';

  @override
  String downloadAdded(String title) {
    return 'Adicionado às transferências: $title';
  }

  @override
  String get downloadPlay => 'Reproduzir o ficheiro';

  @override
  String get downloadEmptyTitle => 'Sem transferências';

  @override
  String get downloadEmptyBody =>
      'Transfira um filme a partir da sua ficha, ou um episódio a partir da série, para ver sem ligação.';

  @override
  String get downloadQueued => 'Em espera';

  @override
  String get downloadPaused => 'Em pausa';

  @override
  String get downloadHeld => 'À espera do fim da reprodução';

  @override
  String get downloadPause => 'Pausar';

  @override
  String get downloadResume => 'Retomar';

  @override
  String get downloadDeleteTitle => 'Eliminar esta transferência?';

  @override
  String downloadDeleteBody(String title) {
    return '$title será removido deste dispositivo.';
  }

  @override
  String get downloadFolder => 'Pasta de transferências';

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
      'Ligação perdida. O ficheiro é mantido: retoma onde parou.';

  @override
  String get downloadErrorServer =>
      'O servidor recusou. Talvez outra reprodução esteja a usar a sua ligação.';

  @override
  String get downloadErrorFormat =>
      'Este conteúdo é transmitido por segmentos e não pode ser transferido.';

  @override
  String get downloadErrorDisk =>
      'Não foi possível escrever: espaço insuficiente ou pasta inacessível.';

  @override
  String get downloadErrorSource =>
      'A fonte desta transferência já não existe.';

  @override
  String get downloadErrorMissing => 'O ficheiro foi movido ou eliminado.';

  @override
  String get downloadFolderChoose => 'Escolher uma pasta';

  @override
  String get downloadFolderReset => 'Pasta predefinida';

  @override
  String get downloadFolderApp => 'Pasta da app, removida com ela';

  @override
  String get downloadFolderHint =>
      'Aplica-se às próximas transferências. As concluídas ficam onde estão.';

  @override
  String get favChooseBody =>
      'Ainda não tem nenhuma lista. Onde quer guardar este favorito?';

  @override
  String get favGlobal => 'Favoritos gerais';

  @override
  String get settingsPhoneTitle => 'Reprodução no telemóvel';

  @override
  String get settingsPip => 'Imagem na imagem';

  @override
  String get settingsPipBody =>
      'O vídeo continua numa pequena janela quando sai da app. Aparece um botão no leitor.';

  @override
  String get settingsRadio => 'Modo rádio';

  @override
  String get settingsRadioBody =>
      'O som continua com o telemóvel bloqueado ou a app em segundo plano. Aparece um botão no leitor.';

  @override
  String get playerPipOn => 'Imagem na imagem ativada';

  @override
  String get playerPipOff => 'Imagem na imagem desativada';

  @override
  String get playerRadioOn => 'Modo rádio ativado';

  @override
  String get playerRadioOff => 'Modo rádio desativado';

  @override
  String get radioNotificationStop => 'Parar';
}
