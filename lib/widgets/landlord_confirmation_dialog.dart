import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LandlordConfirmationDialog extends StatefulWidget {
  const LandlordConfirmationDialog({Key? key}) : super(key: key);

  @override
  _LandlordConfirmationDialogState createState() =>
      _LandlordConfirmationDialogState();
}

class _LandlordConfirmationDialogState
    extends State<LandlordConfirmationDialog> {
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _onConfirm() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.registerAsLandlord();
    
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      Navigator.pushReplacementNamed(context, '/profile');
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Error al registrar como arrendador';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'Error al registrar arrendador'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Quieres registrarte como arrendador?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecciona "Confirmar" para convertirte en arrendador.',
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }
}