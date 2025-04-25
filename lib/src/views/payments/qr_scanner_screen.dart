// lib/screens/payments/qr_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gam3ya/src/controllers/payment_provider.dart';
import 'package:gam3ya/src/models/payment_model.dart';
import 'package:gam3ya/src/services/notification_service.dart';
import 'package:gam3ya/src/widgets/animations/slide_animation.dart';
import 'package:gam3ya/src/widgets/common/error_widget.dart';
import 'package:gam3ya/src/widgets/common/loading_indicator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  final String gam3yaId;
  
  const QRScannerScreen({
    super.key,
    required this.gam3yaId,
  });

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> with TickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  
  bool _isProcessing = false;
  bool _isSuccessful = false;
  String _errorMessage = '';
  String _successMessage = '';
  
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _scannerController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _processQRCode(String code) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });
    
    try {
      // Parse QR code data
      final paymentData = _parseQRCode(code);
      
      if (paymentData == null) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Invalid QR code format. Please try again.';
        });
        return;
      }
      
      // Verify this is for the correct Gam3ya
      if (paymentData['gam3yaId'] != widget.gam3yaId) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'This QR code is for a different Gam3ya. Please check and try again.';
        });
        return;
      }
      
      // Process payment verification
      final isVerified = await ref.read(paymentNotifierProvider.notifier).verifyPayment(
         widget.gam3yaId,
        paymentData['paymentId'],
         paymentData['verificationCode'],
      );
      
      if (isVerified) {
        _scannerController.stop();
        setState(() {
          _isSuccessful = true;
          _isProcessing = false;
          _successMessage = 'Payment successfully verified!';
        });
        
        // Show success notification
        NotificationService().showLocalNotification(
          id: 1,
          title: 'Payment Verified',
          body: 'Your cash payment has been successfully verified.',
          payload: '',
        );
        
        // Animate success
        _animationController.forward();
        
        // Go back after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Failed to verify payment. Please try again or contact support.';
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }
  
  Map<String, dynamic>? _parseQRCode(String code) {
    try {
      // Expected format: gam3ya_id:payment_id:verification_code
      final parts = code.split(':');
      if (parts.length != 3) return null;
      
      return {
        'gam3yaId': parts[0],
        'paymentId': parts[1],
        'verificationCode': parts[2],
      };
    } catch (e) {
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Payment QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.white);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                  case TorchState.auto:
                    return const Icon(Icons.flash_auto, color: Colors.orange);
                  case TorchState.unavailable:
                    return const Icon(Icons.flash_off, color: Colors.white);
                }
              },
            ),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _scannerController,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // QR Scanner
                MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty && !_isProcessing && !_isSuccessful) {
                      final String code = barcodes.first.rawValue ?? '';
                      if (code.isNotEmpty) {
                        _processQRCode(code);
                      }
                    }
                  },
                ),
                
                // Scanner overlay
                _buildScannerOverlay(),
                
                // Processing indicator
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: LoadingIndicator(message: 'Verifying payment...'),
                    ),
                  ),
                
                // Success animation
                if (_isSuccessful)
                  SlideAnimation(
                    controller: _animationController,
                    child: _buildSuccessWidget(),
                  ),
                
                // Error message
                if (_errorMessage.isNotEmpty && !_isProcessing)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ErrorDisplayWidget(
                      message: _errorMessage,
                      onRetry: () {
                        setState(() {
                          _errorMessage = '';
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Scan the QR code provided by the Gam3ya organizer to verify your cash payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gam3ya ID: ${widget.gam3yaId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Corner indicators
          ..._buildCornerIndicators(),
        ],
      ),
    );
  }
  
  List<Widget> _buildCornerIndicators() {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const width = 20.0;
    const thickness = 3.0;
    
    return [
      // Top left
      Positioned(
        top: MediaQuery.of(context).size.height / 2 - 125,
        left: MediaQuery.of(context).size.width / 2 - 125,
        child: Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: primaryColor, width: thickness),
              left: BorderSide(color: primaryColor, width: thickness),
            ),
          ),
        ),
      ),
      // Top right
      Positioned(
        top: MediaQuery.of(context).size.height / 2 - 125,
        right: MediaQuery.of(context).size.width / 2 - 125,
        child: Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: primaryColor, width: thickness),
              right: BorderSide(color: primaryColor, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom left
      Positioned(
        bottom: MediaQuery.of(context).size.height / 2 - 125,
        left: MediaQuery.of(context).size.width / 2 - 125,
        child: Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: primaryColor, width: thickness),
              left: BorderSide(color: primaryColor, width: thickness),
            ),
          ),
        ),
      ),
      // Bottom right
      Positioned(
        bottom: MediaQuery.of(context).size.height / 2 - 125,
        right: MediaQuery.of(context).size.width / 2 - 125,
        child: Container(
          width: width,
          height: width,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: primaryColor, width: thickness),
              right: BorderSide(color: primaryColor, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }
  
  Widget _buildSuccessWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _successMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Returning to payment screen...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}