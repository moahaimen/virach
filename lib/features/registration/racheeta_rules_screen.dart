import 'package:flutter/material.dart';

class RacheetaRulesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شروط واحكام استخدام راجيته'),
        backgroundColor: Colors.blue,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'شروط واحكام استخدام تطبيق راجيته:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 10),
              Text(
                '1. يجب على المستخدم الالتزام بكافة الشروط الخاصة باستخدام التطبيق.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '2. لا يجوز استخدام التطبيق إلا للأغراض الشخصية ولا يسمح باستخدامه لأغراض تجارية.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '3. لا يجوز نشر أي محتوى مسيء أو غير قانوني عبر التطبيق.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '4. إدارة التطبيق غير مسؤولة عن أي بيانات خاطئة يقدمها المستخدم.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '5. يجب على المستخدمين الحفاظ على سرية معلومات تسجيل الدخول وعدم مشاركتها مع أي طرف ثالث.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '6. تحتفظ إدارة التطبيق بالحق في تعليق أو إلغاء الحسابات التي تنتهك الشروط والأحكام.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '7. يتم جمع البيانات الشخصية للمستخدمين وفقًا لسياسة الخصوصية الخاصة بالتطبيق.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                '8. باستخدامك للتطبيق، فإنك توافق على الشروط والأحكام الموضحة أعلاه.',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
