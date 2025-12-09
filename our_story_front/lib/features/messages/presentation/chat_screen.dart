import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_service.dart';
import '../data/models/message_model.dart';
import '../data/repositories/chat_repository.dart';
import '../data/services/chat_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isPartnerTyping = false;
  
  int? _userId;
  int? _coupleId;
  String? _partnerName;
  
  StreamSubscription? _messageSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;
  @override
  void initState() {
    super.initState();
    _initUserData();
    _messageController.addListener(_onTextChanged);
  }
  @override
  void dispose() {
    // Primero cancelar el timer de typing
    _typingTimer?.cancel();
    
    // Remover listener del controller
    _messageController.removeListener(_onTextChanged);
    
    // Cancelar subscripciones de streams ANTES de disponer el servicio
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    
    // Disponer el servicio de chat (esto cierra la conexión WebSocket)
    _chatService.dispose();
    
    // Finalmente disponer los controllers
    _messageController.dispose();
    _scrollController.dispose();
    
    super.dispose();
  }
  Future<void> _initUserData() async {
    try {
      final userData = await _userService.getCurrentUserData();
      if (userData != null) {
        setState(() {
          _userId = userData['userId'] as int?;
          _coupleId = userData['coupleId'] as int?;
          _partnerName = userData['partnerName'] as String?;
        });
        
        if (_coupleId != null) {
          await _loadMessages();
          await _connectWebSocket();
        }
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final messages = await _chatRepository.getMessages();
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar mensajes: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  Future<void> _connectWebSocket() async {
    if (_coupleId == null) return;
    try {
      await _chatService.connect(_coupleId!);
      
      // Listen to new messages
      _messageSubscription = _chatService.messageStream.listen((message) {
        if (!mounted) return;
        setState(() {
          // Update existing message or add new one
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = message;
          } else {
            _messages.add(message);
          }
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        });
        
        _scrollToBottom();
        
        // Mark as read if not sent by current user
        if (message.senderId != _userId && !message.isRead) {
          _chatService.markAsRead(message.id!);
        }
      });
      // Listen to typing notifications
      _typingSubscription = _chatService.typingStream.listen((notification) {
        if (!mounted) return;
        if (notification.userId != _userId) {
          setState(() {
            _isPartnerTyping = notification.isTyping;
          });
        }
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al conectar chat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  void _onTextChanged() {
    if (_userId == null || _coupleId == null) return;
    
    // Cancel previous timer
    _typingTimer?.cancel();
    
    // Send typing notification
    if (_messageController.text.isNotEmpty) {
      _chatService.sendTypingNotification(_userId!, _coupleId!, true);
      
      // Stop typing after 2 seconds of inactivity
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _chatService.sendTypingNotification(_userId!, _coupleId!, false);
      });
    } else {
      _chatService.sendTypingNotification(_userId!, _coupleId!, false);
    }
  }
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _userId == null || _coupleId == null) {
      return;
    }
    final content = _messageController.text.trim();
    _messageController.clear();
    
    // Stop typing notification
    _chatService.sendTypingNotification(_userId!, _coupleId!, false);
    setState(() {
      _isSending = true;
    });
    try {
      final message = MessageModel(
        coupleId: _coupleId!,
        senderId: _userId!,
        senderName: 'Tú',
        content: content,
        msgType: 'TEXT',
        createdAt: DateTime.now(),
      );
      // Send via WebSocket
      _chatService.sendMessage(message);
      
      setState(() {
        _isSending = false;
      });
      
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar mensaje: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
  void _scrollToBottom() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      
      if (_scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _partnerName ?? 'Chat',
                    style: AppTheme.heading3.copyWith(fontSize: 16),
                  ),
                  if (_isPartnerTyping)
                    Text(
                      'escribiendo...',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.accentPrimaryLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Messages list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.accentPrimaryLight),
                      )
                    : _messages.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppSizes.paddingM),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              final isMe = message.senderId == _userId;
                              final showDateSeparator = index == 0 ||
                                  !_isSameDay(
                                    message.createdAt,
                                    _messages[index - 1].createdAt,
                                  );
                              return Column(
                                children: [
                                  if (showDateSeparator)
                                    _buildDateSeparator(message.createdAt),
                                  _buildMessageBubble(message, isMe),
                                ],
                              );
                            },
                          ),
              ),
              // Message input
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: AppSizes.paddingM,
                      right: AppSizes.paddingM,
                      top: AppSizes.paddingM,
                      bottom: AppSizes.paddingM,
                    ),
                    decoration: const BoxDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.textSecondaryLight,
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: AppTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: _coupleId == null 
                                    ? 'Empareja primero para chatear...'
                                    : 'Escribe un mensaje...',
                                hintStyle: AppTheme.bodyMedium.copyWith(
                                  color: AppColors.textPrimaryLight,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              enabled: !_isSending && _coupleId != null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.accentPrimaryLight, AppColors.accentPrimaryLight],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.textPrimaryLight,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded, color: AppColors.textPrimaryLight),
                            onPressed: (_isSending || _coupleId == null) ? null : _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: isMe 
                  ? AppColors.accentPrimaryLight.withValues(alpha: 0.9)
                  : AppColors.accentSecondaryLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMe 
                    ? AppColors.textPrimaryLight.withValues(alpha: 0.5)
                    : AppColors.backgroundCardLight,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.createdAt),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppColors.accentSpecialLight,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                        size: 14,
                        color: message.isRead
                            ? AppColors.info
                            : AppColors.textPrimaryLight.withValues(alpha: 0.7),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (messageDate == today) {
      dateText = 'Hoy';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Ayer';
    } else {
      dateText = DateFormat('dd MMM yyyy', 'es').format(date);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundCardLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.backgroundCardLight,
          width: 1,
        ),
      ),
      child: Text(
        dateText,
        style: AppTheme.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    // Si no tiene pareja, mostrar mensaje diferente
    if (_coupleId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 100,
              color: AppColors.textPrimaryLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Text(
              'No tienes pareja aún',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSizes.paddingS),
            Text(
              'Empareja con alguien para comenzar a chatear',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }
    
    // Si tiene pareja pero no hay mensajes
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 100,
            color: AppColors.textPrimaryLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppSizes.paddingL),
          Text(
            'No hay mensajes aún',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            'Envía el primer mensaje a tu pareja',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
