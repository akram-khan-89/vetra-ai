import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgentTraceOverlay extends StatefulWidget {
  final String caseId;
  final bool visible;
  final VoidCallback onClose;
  final String? dismissStep;

  const AgentTraceOverlay({
    super.key,
    required this.caseId,
    required this.visible,
    required this.onClose,
    this.dismissStep,
  });

  @override
  State<AgentTraceOverlay> createState() => _AgentTraceOverlayState();
}

class _AgentTraceOverlayState extends State<AgentTraceOverlay> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _previousDocs = [];
  bool _dismissTriggered = false;

  @override
  void didUpdateWidget(AgentTraceOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _dismissTriggered = false;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) {
      final dt = DateTime.now();
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
    }
    final dt = timestamp.toDate();
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";
  }

  Color _getStepColor(String step) {
    switch (step.toLowerCase()) {
      case 'listen':
        return const Color(0xFF00E5FF); // Glowing cyan
      case 'diagnose':
        return const Color(0xFFE040FB); // Glowing purple
      case 'discover':
        return const Color(0xFF00E676); // Glowing green
      case 'decide':
        return const Color(0xFFFFD700); // Glowing gold
      case 'execute':
        return const Color(0xFFFF1744); // Glowing red
      default:
        return Colors.white70;
    }
  }

  String _getStepLabel(String step) {
    switch (step.toLowerCase()) {
      case 'listen':
        return 'LISTEN';
      case 'diagnose':
        return 'DIAGNOSE';
      case 'discover':
        return 'DISCOVER';
      case 'decide':
        return 'DECIDE';
      case 'execute':
        return 'EXECUTE';
      default:
        return step.toUpperCase();
    }
  }

  void _exportLogs(List<DocumentSnapshot> docs) {
    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No traces to export yet.')),
      );
      return;
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('=== VETRA AI AGENT REASONING TRACES ===');
    buffer.writeln('Case ID: ${widget.caseId}');
    buffer.writeln('Export Date: ${DateTime.now().toLocal()}\n');

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final step = _getStepLabel(data['step'] ?? 'unknown');
      final time = _formatTime(data['timestamp'] as Timestamp?);
      final reasoning = data['reasoning'] ?? 'No reasoning provided';
      
      String detailsStr = '';
      if (data['output'] != null && data['output'] is Map) {
        final out = data['output'] as Map;
        if (out.containsKey('confidence')) {
          detailsStr = ' (Confidence: ${out['confidence']}%)';
        } else if (out.containsKey('decision_score')) {
          detailsStr = ' (Score: ${out['decision_score']})';
        }
      }

      buffer.writeln('[$time] $step$detailsStr\nReasoning: $reasoning\n');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString())).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reasoning traces copied to clipboard!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.8;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      top: 0,
      bottom: 0,
      left: widget.visible ? 0 : screenWidth,
      right: widget.visible ? 0 : -panelWidth,
      child: Stack(
        children: [
          // Tappable semi-transparent barrier area (left 20%)
          if (widget.visible)
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                color: Colors.black.withOpacity(0.15),
              ),
            ),

          // Sliding Frosted Glass Panel (right 80%)
          Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.8,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.white12, width: 1.5),
                  ),
                ),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                    child: Container(
                      color: const Color(0xAA121212), // Translucent black background
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            _buildHeader(),
                            const Divider(color: Colors.white24, height: 1),

                            // Real-time traces list
                            Expanded(
                              child: _buildTracesStream(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agent_traces')
            .where('case_id', isEqualTo: widget.caseId)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.hasData ? snapshot.data!.docs : <DocumentSnapshot>[];
          docs.sort((a, b) {
            final aTime = (a.data() as Map)['timestamp'] as Timestamp?;
            final bTime = (b.data() as Map)['timestamp'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return aTime.compareTo(bTime);
          });

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology, color: Colors.greenAccent, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Agent Reasoning',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Case: ${widget.caseId}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy_all, color: Colors.greenAccent, size: 20),
                    tooltip: 'Copy all logs',
                    onPressed: () => _exportLogs(docs),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 22),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTracesStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('agent_traces')
          .where('case_id', isEqualTo: widget.caseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Sort in memory to avoid index requirements
        docs.sort((a, b) {
          final aTime = (a.data() as Map)['timestamp'] as Timestamp?;
          final bTime = (b.data() as Map)['timestamp'] as Timestamp?;
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return aTime.compareTo(bTime);
        });

        // Auto-dismiss check
        if (widget.dismissStep != null && !_dismissTriggered) {
          final hasDismiss = docs.any((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final step = data['step'] as String?;
            return step?.toLowerCase() == widget.dismissStep!.toLowerCase();
          });
          
          if (hasDismiss) {
            _dismissTriggered = true;
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && widget.visible) {
                widget.onClose();
              }
            });
          }
        }

        if (docs.length > _previousDocs.length) {
          _previousDocs = List.from(docs);
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.blur_on, size: 48, color: Colors.white30),
                  const SizedBox(height: 12),
                  const Text(
                    'Agent listening to details...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reasoning streams here live.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final step = data['step'] ?? 'unknown';
            final reasoning = data['reasoning'] ?? 'No reasoning details provided';
            final timestamp = data['timestamp'] as Timestamp?;
            final timeStr = _formatTime(timestamp);
            final stepColor = _getStepColor(step);
            final stepLabel = _getStepLabel(step);

            String? metricLabel;
            String? metricValue;
            if (data['output'] != null && data['output'] is Map) {
              final out = data['output'] as Map;
              if (out.containsKey('confidence')) {
                metricLabel = 'Confidence';
                metricValue = '${out['confidence']}%';
              } else if (out.containsKey('completeness_score')) {
                metricLabel = 'Completeness';
                metricValue = '${out['completeness_score']}/100';
              } else if (out.containsKey('decision_score')) {
                metricLabel = 'Match Score';
                metricValue = '${out['decision_score']}/100';
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04), // Glassmorphic card
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white10, width: 0.8),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: stepColor, width: 3),
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              stepLabel,
                              style: TextStyle(
                                color: stepColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 10,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                        if (metricLabel != null && metricValue != null)
                          Text(
                            '$metricLabel: $metricValue',
                            style: TextStyle(
                              color: stepColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 12),
                    Text(
                      reasoning,
                      style: const TextStyle(
                        color: Colors.white70, // Translucent white for readability
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
