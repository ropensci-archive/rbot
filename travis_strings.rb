$travis_file_missing = 'language: r
sudo: false
cache: packages
dist: trusty

r_github_packages:
  - MangoTheCat/goodpractice

after_success:
  - Rscript -e \'Sys.setenv(NOT_CRAN = "true"); x = goodpractice::gp(); z = paste0(capture.output(x), collapse="\\n"); cat(z, file = "summary.txt");  goodpractice::export_json(x, sprintf("ropensci_check_foobar3_%s.json", gsub(":|-", "_", format(Sys.time(), format="%y-%h-%d_%T")))); x\'

addons:
  artifacts:
    s3_region: "us-west-2"
    paths:
    - $(git ls-files -o | grep -e \'.txt\' -e \'.json\' | tr "\n" ":")

env:
  global:
  - secure: KFe8TC/6g5WOhrs7yZWpr/kQvogmTd5bjZPGzZZFz8gYEKvwQk5G1oucZGa6eXpXa6GQjAD+RBZI2KQgBcSFefPsP7drMqTpurjAx5VqQ4nAP/rSEHK64icFgEmX5I2cWKw+Pv2OYnOjMXZYG6bNOk9JVHp8MQStGzhpZO479lG1M7zBggmKMHisUnFPYQkqoeR1FMB7Wgg04VJr/dKGLRe/bhCQmrHSQfUN6DFcyth/xOfPYRXfKoc/z3/J8+nnz3MOlq4c965Jq3Y/JuYhMEeUa0rxWXs6LNAS+j3TFo8w/uIDmSZ0BPjisJLuJDbvi9q3hvjhfWTX3K7wUSAxtQo8YS9m7jLXCMrppWRtCi+AlC9z14KLexw/hB3ii86ti0PLuvMm83Y77SJbSgv0R+xCrU3A7xKPsaF4xsd13yDzlQnr/aMm1HF26jua3DPvTi9jSlsL3jbtdBzXGtuCxOX4UCk22Hp/MiV3H+NAeYPz0yDcclnpmDwrTpa8et1lLafnXYGYGTO7q7qhCLdpP02pqYHfZJSwkHhfft2AW3Kcmqhlsy7kjqqUE8VEwSYPghbQb2RQT4LoiwUprid1IRDBQUv7XggQcMfQB3m4JlejmJCNToFHT/eo5ogsKwuUWw/ZwMa/o7FVV0axUUrtohbIPCUbXVos+7w2xEFU5sw=
  - secure: TckGsBbLUfyLYujOJ4dph5/3QG1Ij4KWlhv3JpdsET8TAjzh/Si99KLSHiH+Qz1zVlHYf8LvhgP8XO9Aeipn7cVB8E5z5JoasUIZV7PTuVjtwqiC8uMRkjpCnxtUM7Wht1Jhj0FkwSuV1z0tRut/2WbNdpiF6OanJsOo9Hngt5ZV3xEZ2/Sm2mXaDvaT4AuPqeAntuKykcKc3Z3CdzvtHv/r/jnEUlrZYnZJ2TKAYZIPs0PcTjT5nL4RGmSMeNDTtXqVMyWIMcYLyi8Zn2EB/ssHTYd5yqJNZNU8i0yjoVCvUWMbut1asDdJ0VDzE6o2t1RJbeCMp1Frof2Pvgg3jLYI6z7DtvisKVPz2cOF4QF0DujrQKIF8BOh/RTL0LvFm55vi+TjmcpvjSq5Qg20qMV0dC9ZKGBL+sZOEiVBfAiESE4/ZrPaamwrcrbwsjkGPmv3+JoRrxem+wwmENn5SpejbXAWrpbyQjm4qq7jJMhFsTE8/sIKsiG+1CulIpTXZ3LlZE0sQpHm2CO7GDZKzDasC5UiRrALIauU4Ne77ANaHc+5MR30x5A0TMHDF5fpYp5+U12zowB1YMfhsRHwX1iqlLjmnQ5SmMWdnJKaqLTR0cZda26LWQqzHtzaFLIRVaY1kSY/EY63ZPN9OuXfsDzwgO+JP7Cl7FvCrsKr5i8=
  - secure: LHmn4L8fCD+wzTvQFolQ/YBanLNtlxzimGIYVoRc6bUvsNOFSIPNzgpwakbTFHf+NPEqvt/JW7urow4R0Yx1FgVXkHZPzHxmM/tpF5Q5DBGgu+bDT+T4YpDG394mbzMPExZCJi0n3dLoCOI1z9+EaMMQEWg9+w+WBa//J4UD4P23BxX5RWl7IcmKh13tV6vWEwu5o6uyx90UulRzsReNNRN6NdsRnZPp5cniE9zlfClSlGeY67Vber03Qim/F28lqhGSp8X6gKPlFfe7BWSXfkOKnd5GlQRLSWl5Uh8cnjYmPblDesq12CQEnYN5kVto1vJywErLfZ7uBY+/ETK6qXY2lBn3Wqzz/elgWfzuGYbcBKrhn29YGKWhXwuPbLYyuG4/b7AS0+qzcPpJHvXXMKiZNk8S8tWC+M5erkZCHLhonNSVXcdjLP21qQZY61xGVqpxqwtK2AXC5TugCOZwqqQf79pEFEBoN7xpuTo/F6OqH8Ar8kmMudOpvoJnYRfWBKbhMFPLqwvywiCsJ9xe5DXOETWtuFF2C/kwwPI5XJYmNgc51N1pv6yw5SRS2l32WLJGynOUGVmud1GFIRMxNgAKmlKZV7ma1vQ/N+P/9wCXF9lPiNr+KX894vzETKgNVtFnRSvFS7JXc/DGKc0uBRjiQibebZdAwDPHcsf0Ayo=

  '

$travis_file_adding = '

r_github_packages:
  - MangoTheCat/goodpractice

after_success:
  - Rscript -e \'Sys.setenv(NOT_CRAN = "true"); x = goodpractice::gp(); z = paste0(capture.output(x), collapse="\\n"); cat(z, file = "summary.txt");  goodpractice::export_json(x, sprintf("ropensci_check_foobar3_%s.json", gsub(":|-", "_", format(Sys.time(), format="%y-%h-%d_%T")))); x\'

addons:
  artifacts:
    s3_region: "us-west-2"
    paths:
    - $(git ls-files -o | grep -e \'.txt\' -e \'.json\' | tr "\n" ":")

env:
  global:
  - secure: KFe8TC/6g5WOhrs7yZWpr/kQvogmTd5bjZPGzZZFz8gYEKvwQk5G1oucZGa6eXpXa6GQjAD+RBZI2KQgBcSFefPsP7drMqTpurjAx5VqQ4nAP/rSEHK64icFgEmX5I2cWKw+Pv2OYnOjMXZYG6bNOk9JVHp8MQStGzhpZO479lG1M7zBggmKMHisUnFPYQkqoeR1FMB7Wgg04VJr/dKGLRe/bhCQmrHSQfUN6DFcyth/xOfPYRXfKoc/z3/J8+nnz3MOlq4c965Jq3Y/JuYhMEeUa0rxWXs6LNAS+j3TFo8w/uIDmSZ0BPjisJLuJDbvi9q3hvjhfWTX3K7wUSAxtQo8YS9m7jLXCMrppWRtCi+AlC9z14KLexw/hB3ii86ti0PLuvMm83Y77SJbSgv0R+xCrU3A7xKPsaF4xsd13yDzlQnr/aMm1HF26jua3DPvTi9jSlsL3jbtdBzXGtuCxOX4UCk22Hp/MiV3H+NAeYPz0yDcclnpmDwrTpa8et1lLafnXYGYGTO7q7qhCLdpP02pqYHfZJSwkHhfft2AW3Kcmqhlsy7kjqqUE8VEwSYPghbQb2RQT4LoiwUprid1IRDBQUv7XggQcMfQB3m4JlejmJCNToFHT/eo5ogsKwuUWw/ZwMa/o7FVV0axUUrtohbIPCUbXVos+7w2xEFU5sw=
  - secure: TckGsBbLUfyLYujOJ4dph5/3QG1Ij4KWlhv3JpdsET8TAjzh/Si99KLSHiH+Qz1zVlHYf8LvhgP8XO9Aeipn7cVB8E5z5JoasUIZV7PTuVjtwqiC8uMRkjpCnxtUM7Wht1Jhj0FkwSuV1z0tRut/2WbNdpiF6OanJsOo9Hngt5ZV3xEZ2/Sm2mXaDvaT4AuPqeAntuKykcKc3Z3CdzvtHv/r/jnEUlrZYnZJ2TKAYZIPs0PcTjT5nL4RGmSMeNDTtXqVMyWIMcYLyi8Zn2EB/ssHTYd5yqJNZNU8i0yjoVCvUWMbut1asDdJ0VDzE6o2t1RJbeCMp1Frof2Pvgg3jLYI6z7DtvisKVPz2cOF4QF0DujrQKIF8BOh/RTL0LvFm55vi+TjmcpvjSq5Qg20qMV0dC9ZKGBL+sZOEiVBfAiESE4/ZrPaamwrcrbwsjkGPmv3+JoRrxem+wwmENn5SpejbXAWrpbyQjm4qq7jJMhFsTE8/sIKsiG+1CulIpTXZ3LlZE0sQpHm2CO7GDZKzDasC5UiRrALIauU4Ne77ANaHc+5MR30x5A0TMHDF5fpYp5+U12zowB1YMfhsRHwX1iqlLjmnQ5SmMWdnJKaqLTR0cZda26LWQqzHtzaFLIRVaY1kSY/EY63ZPN9OuXfsDzwgO+JP7Cl7FvCrsKr5i8=
  - secure: LHmn4L8fCD+wzTvQFolQ/YBanLNtlxzimGIYVoRc6bUvsNOFSIPNzgpwakbTFHf+NPEqvt/JW7urow4R0Yx1FgVXkHZPzHxmM/tpF5Q5DBGgu+bDT+T4YpDG394mbzMPExZCJi0n3dLoCOI1z9+EaMMQEWg9+w+WBa//J4UD4P23BxX5RWl7IcmKh13tV6vWEwu5o6uyx90UulRzsReNNRN6NdsRnZPp5cniE9zlfClSlGeY67Vber03Qim/F28lqhGSp8X6gKPlFfe7BWSXfkOKnd5GlQRLSWl5Uh8cnjYmPblDesq12CQEnYN5kVto1vJywErLfZ7uBY+/ETK6qXY2lBn3Wqzz/elgWfzuGYbcBKrhn29YGKWhXwuPbLYyuG4/b7AS0+qzcPpJHvXXMKiZNk8S8tWC+M5erkZCHLhonNSVXcdjLP21qQZY61xGVqpxqwtK2AXC5TugCOZwqqQf79pEFEBoN7xpuTo/F6OqH8Ar8kmMudOpvoJnYRfWBKbhMFPLqwvywiCsJ9xe5DXOETWtuFF2C/kwwPI5XJYmNgc51N1pv6yw5SRS2l32WLJGynOUGVmud1GFIRMxNgAKmlKZV7ma1vQ/N+P/9wCXF9lPiNr+KX894vzETKgNVtFnRSvFS7JXc/DGKc0uBRjiQibebZdAwDPHcsf0Ayo=

  '
