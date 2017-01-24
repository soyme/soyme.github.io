---
layout: post
title: Node.js login with passport (Express 4)
category: blog
tags: [javascript]

---

passport를 이용하여 간단하게 로그인, 로그아웃 및 세션 관리 구현하기.

- express-session
- passport
- passport-local
- connect-flash
- bcrypt


<!-- more -->

#### app.js
```javascript
...
var expressSession = require('express-session');
var passport = require('passport');
require('./passport')(passport);
var flash = require('connect-flash');

app.use(expressSession({
    secret: 'foo',
    resave: false,
    saveUninitialized: true
}));

app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

// for route
var routes = require('./routes/index');
app.use('/', routes);
...
```

#### passport.js
```javascript
var LocalStrategy = require('passport-local').Strategy;
var bcrypt = require('bcrypt-nodejs');
var salt = bcrypt.genSaltSync(10);

var userDao = require('./dao/UserDao');

module.exports = function(passport) {
    passport.use('login', new LocalStrategy({
        usernameField: 'id',
        passwordField: 'ps',
        passReqToCallback : true
    }, function(req, id, ps, done) {
        // TODO implement userDao
        userDao.getUser(id, function(err, row) {
            if (err) {
                return done(err);
            }

            if (!row){
                return done(null, false, req.flash('message', 'User Not found.'));
            }

            if (!bcrypt.compareSync(ps, row.ps)) {
                return done(null, false, req.flash('message', 'Invalid Password'));
            }

            return done(null, row);
        });
    }));

    passport.serializeUser(function(user, done) {
        done(null, user.id);
    });

    passport.deserializeUser(function(id, done) {
        // TODO implement userDao
        userDao.getUser(id, function(err, row) {
            return done(err, row);
        });
    });
};
```

#### routes/index.js
```javascript
var express = require('express');
var router = express.Router();
var passport = require('passport');
var logger = require('log4js').getLogger('routes/index.js');

router.get('/', function(req, res, next) {
    res.render('index', { title: 'hello world', message: req.flash('message') });
});

router.post('/login', passport.authenticate('login', {
    successRedirect: '/user',
    failureRedirect: '/',
    failureFlash : true
}));

router.get('/user', function(req, res){
    res.render('user', { message:  'Hello, ' + req.user.id });
});

router.get('/logout', isLoggedIn, function(req, res){
    req.logout();
    res.redirect('/');
});

function isLoggedIn(req, res, next) {
    if (req.isAuthenticated()) {
        return next();
    }

    res.redirect('/');
}

module.exports = router;
```

