import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/products.dart';
import '/providers/product.dart';

class EditProductsScreen extends StatefulWidget {
  const EditProductsScreen({Key? key}) : super(key: key);
  static const routeName = '/edit_products';

  @override
  _EditProductsScreenState createState() => _EditProductsScreenState();
}

class _EditProductsScreenState extends State<EditProductsScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: '',
    title: '',
    description: '',
    price: 00,
    imageUrl: '',
  );
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageURL': ''
  };

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((_imageUrlController.text.isEmpty) ||
          (!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .findById(productId.toString());
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageURL': ''
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final _isValid = _form.currentState!.validate();
    if (!_isValid) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != '') {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurror'),
            content: const Text('Something went wrong'),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      initialValue: _initValues['title'],
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: value!,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      initialValue: _initValues['price'],
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number.';
                        }
                        if (double.tryParse(value)! <= 0) {
                          return 'Please enter a value greater than zero.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(value!),
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      initialValue: _initValues['description'],
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please provide a value.';
                        }
                        if (value.length < 10) {
                          return ' Should be at least 10 characters long';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                            id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: value!.toString(),
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl);
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            color: Colors.grey,
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('Enter a url')
                              : FittedBox(
                                  child: Image.network(
                                  _imageUrlController.text,
                                  fit: BoxFit.cover,
                                )),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Image URL'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a URL';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Please entter a valid URL.';
                              }
                              if (!value.endsWith('.jpg') &&
                                  !value.endsWith('.png') &&
                                  !value.endsWith('.jpeg')) {
                                return 'Please enter a valid image URL';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                  id: _editedProduct.id,
                                  isFavorite: _editedProduct.isFavorite,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: value!);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
