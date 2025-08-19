create database if not exists `headerdb`;
grant all privileges on headerdb.* to 'ohgiraffers'@'%';

use `headerdb`;

-- drop table
drop table if exists tbl_shop_msg_history;
drop table if exists tbl_msg_send_batch;
drop table if exists tbl_visitors;
drop table if exists tbl_sales;
drop table if exists tbl_reservation;
drop table if exists tbl_message_template;
drop table if exists tbl_menu;
drop table if exists tbl_menu_category;
drop table if exists tbl_shop_holiday;
drop table if exists tbl_shop;
drop table if exists tbl_shop_category;
drop table if exists tbl_user;

-- user table
create table if not exists `tbl_user`
(
    `user_code`  int primary key auto_increment,
    `user_id`    varchar(20)  null comment '아이디',
    `user_pwd`   varchar(255) null comment '비밀번호',
    `is_admin`   boolean      not null default 0 comment '관리자여부',
    `user_name`  varchar(255) not null comment '이름',
    `user_phone` varchar(20)  not null comment '전화번호',
    `birthday`   date         null comment '고객생일',
    `is_leave`   boolean      not null default 0 comment '탈퇴여부'
    );

-- shop_category table
create table if not exists `tbl_shop_category`
(
    `category_code` int primary key auto_increment,
    `category_name` varchar(50) not null comment '카테고리 이름'
    );

-- shop table
create table if not exists `tbl_shop`
(
    `shop_code`     int primary key auto_increment,
    `category_code` int            not null comment '샵 유형 코드',
    `admin_code`    int            not null comment '관리자 코드',
    `shop_name`     varchar(50)    not null comment '샵 이름',
    `shop_phone`    varchar(20)    not null comment '샵 전화번호',
    `shop_location` varchar(255)   not null comment '샵 주소',
    `shop_long`     decimal(10, 7) not null comment '샵 경도',
    `shop_la`       decimal(10, 7) not null comment '샵 위도', -- 샵 휴일 테이블 추가 후 샵 상태 컬럼 삭제
    `shop_open`     varchar(5)     not null comment '샵 운영시간',
    `shop_close`    varchar(5)     not null comment '샵 닫는시간',
    `is_active`     boolean        not null default 1 comment '활성 여부'
    );

create table if not exists `tbl_shop_holiday`
(
    `shop_hol_code` int primary key auto_increment,
    `shop_code`    int     not null,
    `hol_start_date`   date    not null comment '적용 시작 날짜',
    `hol_end_date`     date    null comment '적용 종료 날짜',
    `is_hol_repeat`    boolean not null default 0 comment '반복 여부'
);

-- menu_category table (modified to include shop_code as fk and composite pk)
create table if not exists `tbl_menu_category`
(
    `category_code` int         not null comment '카테고리 코드',
    `shop_code`     int         not null comment '샵 코드',
    `category_name` varchar(40) not null comment '카테고리명',
    `menu_color`    varchar(20) not null comment '대표 색상',
    `is_active`     boolean     not null default 1 comment '활성 여부',
    primary key (`category_code`, `shop_code`)
    );

-- menu table (modified to remove shop_code direct fk, now references through menu_category)
create table if not exists `tbl_menu`
(
    `menu_code`     int primary key auto_increment,
    `category_code` int         not null comment '카테고리 코드',
    `shop_code`     int         not null comment '샵 코드',
    `menu_name`     varchar(40) not null comment '시술명',
    `menu_price`    int         not null comment '시술가격',
    `est_time`      int         not null comment '예상소요시간',
    `is_active`     boolean     not null default 1 comment '활성 여부'
    );

-- message_template table
create table if not exists `tbl_message_template`
(
    `template_code`    int primary key auto_increment,
    `shop_code`        int comment '샵 코드',
    `template_title`   varchar(50)  not null comment '템플릿 제목',
    `template_content` varchar(255) not null comment '템플릿 내용',
    `template_type`    varchar(20)  not null comment '템플릿 타입'
    );

-- reservation table
create table if not exists `tbl_reservation`
(
    `resv_code`    int primary key auto_increment,
    `user_code`    int          not null comment '회원코드',
    `shop_code`    int          not null comment '샵 코드',
    `menu_code`    int          not null comment '시술 코드',
    `resv_date`    date         not null comment '예약 날짜',
    `resv_time`    time         not null comment '예약 시간',
    `user_comment` varchar(255) null comment '메모',
    `resv_state`   varchar(20)  not null default '예약확정' comment '예약 상태'
    );

-- sales table (modified pay_datetime to datetime)
create table if not exists `tbl_sales`
(
    `sales_code`      int primary key auto_increment,
    `resv_code`       int          not null comment '예약코드',
    `pay_amount`      int          not null comment '결제 금액',
    `pay_method`      varchar(20)  not null comment '결제 수단',
    `pay_datetime`    datetime     not null comment '결제일시',
    `pay_status`      varchar(20)  not null default 'completed' comment '결제상태 (completed, cancelled, partial_cancelled, deleted)',

    -- 취소 관련 컬럼 추가
    `cancel_amount`   int          null     default 0 comment '취소 금액',
    `cancel_datetime` datetime     null comment '취소일시',
    `cancel_reason`   varchar(255) null comment '취소 사유',
    `final_amount`    int          not null comment '최종 결제 금액 (결제금액 - 취소금액)'
    );

-- visitors table
create table if not exists `tbl_visitors`
(
    `client_code` int primary key auto_increment,
    `user_code`   int          not null comment '회원코드',
    `shop_code`   int          not null comment '샵 코드',
    `memo`        varchar(255) null comment '메모',
    `sendable`    boolean      not null default 0 comment '광고성수신여부',
    `is_active`   boolean      not null default 1 comment '활성여부'
    );

-- tbl_msg_send_batch
create table if not exists `tbl_msg_send_batch`
(
    `batch_code`    int primary key auto_increment comment '발송 배치 코드',
    `shop_code`     int         not null comment '샵 코드',
    `template_code` int comment '사용된 템플릿 코드',
    `send_date`     date        not null comment '발송 날짜',
    `send_time`     time        not null comment '발송 시간',
    `send_type`     varchar(20) not null comment '발송 타입 (individual, group)',

    `subject`       varchar(100) comment '메시지 제목/요약',

    `total_count`   int       default 0 comment '총 발송 건수',
    `success_count` int       default 0 comment '성공 건수',
    `fail_count`    int       default 0 comment '실패 건수',
    `created_at`    timestamp default current_timestamp,
    index idx_shop_batch (`shop_code`, `batch_code`),
    index idx_shop_date (`shop_code`, `send_date`),
    index idx_created_at (created_at)
    );

-- shop_msg_history table
create table if not exists `tbl_shop_msg_history`
(
    `history_code`  int primary key auto_increment comment '히스토리 코드',
    `batch_code`    int         not null comment '발송 배치 코드',
    `user_code`     int         not null comment '수신자',
    `msg_content`   text        not null comment '실제 발송된 메시지 내용',
    `send_status`   varchar(20) not null comment '발송 상태 (pending, success, fail)',
    `error_message` varchar(255) comment '오류 메시지',
    `sent_at`       timestamp comment '실제 발송 시간',

    foreign key (`batch_code`) references `tbl_msg_send_batch` (`batch_code`) on delete cascade,
    index idx_batch_code (`batch_code`),
    index idx_user_code (`user_code`),
    index idx_send_status (`send_status`),
    index idx_history_user (`history_code`, `user_code`)
    );

-- set foreign key constraints
alter table `tbl_shop`
    add constraint `fk_tbl_shop_category_to_shop_1` foreign key (`category_code`) references `tbl_shop_category` (`category_code`);
alter table `tbl_shop`
    add constraint `fk_tbl_user_to_shop_1` foreign key (`admin_code`) references `tbl_user` (`user_code`);

-- tbl_shop_holiday에 대한 fk(shop_code) 추가
alter table `tbl_shop_holiday`
    add constraint `fk_tbl_shop_to_shop_holiday_1` foreign key (`shop_code`) references `tbl_shop` (`shop_code`);

-- modified fk for menu_category (now references shop table)
alter table `tbl_menu_category`
    add constraint `fk_tbl_shop_to_menu_category_1` foreign key (`shop_code`) references `tbl_shop` (`shop_code`);

-- modified fk for menu (now references menu_category with composite key)
alter table `tbl_menu`
    add constraint `fk_tbl_menu_category_to_menu_1` foreign key (`category_code`, `shop_code`) references `tbl_menu_category` (`category_code`, `shop_code`);

alter table `tbl_message_template`
    add constraint `fk_tbl_shop_to_message_template_1` foreign key (`shop_code`) references `tbl_shop` (`shop_code`);

alter table `tbl_reservation`
    add constraint `fk_tbl_user_to_reservation_1` foreign key (`user_code`) references `tbl_user` (`user_code`);
alter table `tbl_reservation`
    add constraint `fk_tbl_shop_to_reservation_1` foreign key (`shop_code`) references `tbl_shop` (`shop_code`);
alter table `tbl_reservation`
    add constraint `fk_tbl_menu_to_reservation_1` foreign key (`menu_code`) references `tbl_menu` (`menu_code`);
alter table `tbl_reservation`
    add constraint uniq_reservation_slot
        unique (shop_code, resv_date, resv_time);

alter table `tbl_sales`
    add constraint `fk_tbl_reservation_to_sales_1` foreign key (`resv_code`) references `tbl_reservation` (`resv_code`);

alter table `tbl_visitors`
    add constraint `fk_tbl_user_to_visitors_1` foreign key (`user_code`) references `tbl_user` (`user_code`);
alter table `tbl_visitors`
    add constraint `fk_tbl_shop_to_visitors_1` foreign key (`shop_code`) references `tbl_shop` (`shop_code`);

alter table `tbl_shop_msg_history`
    add constraint `fk_tbl_user_to_shop_msg_history_1` foreign key (`user_code`) references `tbl_user` (`user_code`);
alter table `tbl_shop_msg_history`
    add constraint `fk_tbl_msg_send_batch_to_shop_msg_history_1` foreign key (`batch_code`) references `tbl_msg_send_batch` (`batch_code`);

alter table `tbl_msg_send_batch`
    add constraint `fk_tbl_message_template_to_msg_send_batch_1` foreign key (`template_code`) references `tbl_message_template` (`template_code`);
alter table `tbl_msg_send_batch`
    add constraint `fk_tbl_shop_to_msg_send_batch_1` foreign key (`shop_code`) references `tbl_shop` (`shop_code`);