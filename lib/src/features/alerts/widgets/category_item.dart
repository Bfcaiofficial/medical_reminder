import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String imageUrl;
  final Function() onCategoryTappedCallback;
  final bool isPng;

  CategoryItem(
      {this.title, this.imageUrl, this.onCategoryTappedCallback, this.isPng});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: Colors.black12.withOpacity(0.05),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onCategoryTappedCallback,
              child: Container(
                height: constraints.maxHeight,
                padding: EdgeInsets.all(constraints.maxHeight * 0.15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                        flex: 4,
                        child: isPng
                            ? Image.asset(imageUrl)
                            : SvgPicture.asset(imageUrl)),
                    SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: FittedBox(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
