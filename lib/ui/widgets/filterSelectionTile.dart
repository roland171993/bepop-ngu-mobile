import 'package:bepop_ngu/ui/widgets/customTextContainer.dart';
import 'package:bepop_ngu/utils/constants.dart';
import 'package:flutter/material.dart';

class FilterSelectionTile extends StatelessWidget {
  final bool isSelected;
  final String title;

  final Function onTap;
  const FilterSelectionTile(
      {super.key,
      required this.onTap,
      required this.isSelected,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {
          onTap.call();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding:
              EdgeInsets.symmetric(horizontal: appContentHorizontalPadding),
          alignment: Alignment.topCenter,
          child: Row(
            children: [
              Expanded(
                  child: CustomTextContainer(
                textKey: title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16.0),
              )),
              const SizedBox(
                width: 15,
              ),
              Container(
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 1.5,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                child: isSelected
                    ? Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary),
                      )
                    : const SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
