# PRD v0.1 — AirPods Tennis Form Coach

## 1. 제품 개요

### 제품명

가칭: **TennisCoach**

### 한 줄 설명

스마트폰 카메라로 사용자의 포핸드·백핸드 스윙을 실시간 분석하고, 스윙 직후 AirPods로 짧은 자세 교정 피드백을 전달하는 iOS 앱.

### 제품 방향

초기 MVP는 **백엔드 없이 온디바이스로 동작하는 실시간 자세 피드백 앱**으로 시작한다.
MVP 검증 후에는 사용자의 세션 데이터와 자세 분석 데이터를 기반으로 **개인화 코칭 플랫폼**으로 확장한다.

---

## 2. 문제 정의

테니스 초보자와 중급자는 스윙 중 자신의 자세 오류를 즉시 인지하기 어렵다. 일반적인 영상 촬영은 사후 분석에는 유용하지만, 실제 연습 중에는 다음 스윙에 바로 반영하기 어렵다.

기존 코칭 앱은 주로 다음 중 하나에 치우쳐 있다.

| 방식 | 한계 |
| --- | --- |
| 녹화 후 영상 분석 | 즉각적인 교정이 어렵다 |
| 사람이 직접 코칭 | 비용과 접근성 문제가 있다 |
| 일반 피트니스 자세 분석 | 테니스 스윙의 phase, 회전, 임팩트 타이밍을 반영하기 어렵다 |
| 고급 테니스 분석 앱 | 공/코트/샷 통계 중심이며 자세 교정 큐는 제한적이다 |

이 제품은 **스윙 직후 바로 들을 수 있는 짧은 교정 큐**에 집중한다.

---

## 3. 목표

### MVP 목표

1. 사용자가 iPhone을 삼각대에 고정하고 포핸드 또는 백핸드 연습을 시작할 수 있다.
2. 앱은 실시간 카메라 입력에서 사용자의 신체 포즈를 추정한다.
3. 앱은 포핸드·백핸드 스윙 중 대표적인 자세 오류를 감지한다.
4. 앱은 스윙 직후 AirPods 또는 현재 오디오 출력 장치로 짧은 음성 피드백을 제공한다.
5. 세션 종료 후 사용자는 반복된 오류와 개선 포인트를 확인할 수 있다.
6. 모든 핵심 기능은 백엔드 없이 온디바이스에서 동작한다.

### MVP에서 검증할 가설

| 가설 | 검증 방식 |
| --- | --- |
| 사용자는 스윙 직후 1개의 짧은 음성 큐를 유용하게 느낀다 | 사용자 테스트, 세션 후 설문 |
| 포핸드·백핸드의 대표 오류는 2D/3D 포즈 추정만으로 일정 수준 감지 가능하다 | 코치 검수, 영상 라벨 비교 |
| 백엔드 없이도 초기 제품 가치를 제공할 수 있다 | 오프라인 세션 수행률 |
| 반복 오류 요약은 다음 연습 목표 설정에 도움이 된다 | 세션 완료 후 재사용률 |

---

## 4. 비목표

MVP에서는 다음을 하지 않는다.

| 제외 항목 | 이유 |
| --- | --- |
| 로그인/회원가입 | 백엔드 없는 MVP에 불필요 |
| 클라우드 동기화 | 초기 검증 단계에서는 로컬 저장으로 충분 |
| 공 추적 | 난도가 높고 MVP 핵심 가치와 분리 가능 |
| 라켓면 분석 | 일반 카메라 포즈 추정만으로 정확도 확보 어려움 |
| 서브 분석 | 포핸드·백핸드보다 동작 phase가 복잡함 |
| 한손 백핸드 고급 교정 | 양손 백핸드와 생체역학 기준이 다름 |
| 랠리 중 완전 자동 코칭 | 공, 상대방, 이동, 가림 문제가 큼 |
| 실시간 문장형 코칭 | 스윙 리듬을 방해할 가능성이 높음 |
| AI 생성형 코칭 채팅 | MVP 핵심 사용 흐름과 무관 |

---

## 5. 타깃 사용자

### Primary Persona: 초급~중급 테니스 사용자

| 항목 | 내용 |
| --- | --- |
| 수준 | 입문자, 초급자, 동호인 중급자 |
| 니즈 | 코치 없이도 기본 자세 오류를 알고 싶음 |
| 환경 | 실내 테니스장, 야외 코트, 볼머신, 셀프 피드, 쉐도우 스윙 |
| 디바이스 | iPhone + AirPods |
| 핵심 문제 | 영상만 보면 무엇을 고쳐야 할지 모름 |

### Secondary Persona: 테니스 코치

| 항목 | 내용 |
| --- | --- |
| 니즈 | 학생의 반복 오류를 기록하고 세션 후 설명하고 싶음 |
| MVP 내 역할 | 직접 타깃은 아니지만, Rule 검수자와 데이터 라벨러로 중요 |
| 향후 확장 | 코치 리뷰, 원격 피드백, 세션 공유 |

---

## 6. 핵심 사용자 시나리오

### 시나리오 1: 포핸드 연습

1. 사용자가 앱을 실행한다.
2. 포핸드 연습 모드를 선택한다.
3. 오른손/왼손을 선택한다.
4. 카메라 촬영 가이드를 보고 iPhone을 삼각대에 고정한다.
5. AirPods를 착용한다.
6. 사용자가 포핸드 스윙을 한다.
7. 앱이 스윙을 감지하고 분석한다.
8. 스윙 종료 직후 “어깨 돌려”, “앞에서 맞춰”, “마무리 높게” 중 하나를 들려준다.
9. 세션 종료 후 반복 오류 요약을 보여준다.

### 시나리오 2: 백핸드 연습

1. 사용자가 백핸드 연습 모드를 선택한다.
2. MVP에서는 기본값을 **양손 백핸드**로 둔다.
3. 앱이 어깨 회전, 몸통 회전, 손과 몸 사이 간격, 팔로스루를 분석한다.
4. 스윙 직후 “몸통 먼저”, “간격 유지”, “끝까지” 같은 짧은 큐를 제공한다.

### 시나리오 3: 세션 종료 후 복습

1. 사용자가 세션을 종료한다.
2. 앱은 전체 스윙 수, 분석 성공률, 주요 반복 오류를 보여준다.
3. 사용자는 다음 세션의 집중 목표를 확인한다.
4. 기록은 로컬에 저장된다.

---

## 7. MVP 범위

### 지원 플랫폼

| 항목 | 결정 |
| --- | --- |
| OS | iOS 우선 |
| UI | SwiftUI |
| 상태 관리 | TCA |
| 아키텍처 | Clean Architecture + Tuist 모듈화 |
| 백엔드 | 없음 |
| 저장소 | 로컬 저장 |
| 포즈 추정 | Apple Vision 우선 검토, MediaPipe 대안 |
| 분석 방식 | 룰 기반 우선 |
| Core ML | MVP 1.5 이후 동작/오류 분류에 사용 |

### 지원 동작

| 동작 | MVP 지원 여부 |
| --- | --- |
| 포핸드 | 지원 |
| 양손 백핸드 | 지원 |
| 한손 백핸드 | 제외 또는 실험 기능 |
| 서브 | 제외 |
| 발리 | 제외 |
| 스매시 | 제외 |

### 지원 환경

| 환경 | MVP 지원 여부 |
| --- | --- |
| 쉐도우 스윙 | 지원 |
| 셀프 피드 | 지원 |
| 볼머신 | 지원 |
| 일반 랠리 | 제한적 지원 또는 제외 |
| 경기 중 분석 | 제외 |

---

## 8. 주요 기능 요구사항

## 8.1 온보딩

### 목적

사용자의 기본 신체·훈련 설정을 수집한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| ONB-001 | 사용자는 오른손잡이/왼손잡이를 선택할 수 있어야 한다 | P0 |
| ONB-002 | 사용자는 주 연습 동작을 선택할 수 있어야 한다 | P0 |
| ONB-003 | 사용자는 백핸드 타입을 선택할 수 있어야 한다 | P1 |
| ONB-004 | 사용자는 AirPods 또는 Bluetooth 오디오 사용 안내를 볼 수 있어야 한다 | P1 |
| ONB-005 | 사용자는 카메라 설치 가이드를 볼 수 있어야 한다 | P0 |

### 초기 입력값

```text
handedness:
  - right
  - left

strokePreference:
  - forehand
  - twoHandBackhand

cameraMode:
  - side
  - rearDiagonal

feedbackFrequency:
  - low
  - normal
  - high
```

---

## 8.2 권한 요청

### 목적

카메라와 오디오 출력 사용을 명확히 안내한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| PERM-001 | 앱은 카메라 권한을 요청해야 한다 | P0 |
| PERM-002 | 권한 거부 시 설정 앱으로 이동할 수 있는 안내를 제공해야 한다 | P0 |
| PERM-003 | 앱은 AirPods 연결이 필수는 아니며 현재 오디오 출력 장치를 사용한다고 안내해야 한다 | P1 |
| PERM-004 | 앱은 영상이 기본적으로 서버에 업로드되지 않는다고 안내해야 한다 | P0 |

---

## 8.3 훈련 설정

### 목적

사용자가 분석할 동작과 촬영 모드를 선택한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| SETUP-001 | 사용자는 포핸드 또는 백핸드를 선택할 수 있어야 한다 | P0 |
| SETUP-002 | 사용자는 측면 촬영 또는 후방 대각선 촬영을 선택할 수 있어야 한다 | P0 |
| SETUP-003 | 앱은 선택한 촬영 모드에 맞는 설치 가이드를 보여줘야 한다 | P0 |
| SETUP-004 | 앱은 전신이 화면에 들어왔는지 확인하는 품질 체크를 제공해야 한다 | P0 |
| SETUP-005 | 앱은 조명 부족, 신체 일부 누락, 카메라 흔들림을 경고해야 한다 | P1 |

---

## 8.4 실시간 촬영

### 목적

카메라 프레임을 받아 포즈 추정과 자세 분석을 수행한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| REC-001 | 앱은 후면 카메라를 사용해 실시간 영상을 입력받아야 한다 | P0 |
| REC-002 | 앱은 프레임을 포즈 추정 엔진으로 전달해야 한다 | P0 |
| REC-003 | 앱은 모든 프레임을 TCA Action으로 보내지 않아야 한다 | P0 |
| REC-004 | 앱은 고수준 CoachingEvent만 Feature 계층으로 전달해야 한다 | P0 |
| REC-005 | 앱은 녹화 중 현재 분석 가능 상태를 UI로 표시해야 한다 | P0 |
| REC-006 | 앱은 세션 시작/중지 기능을 제공해야 한다 | P0 |
| REC-007 | 앱은 앱이 백그라운드로 이동하면 세션을 일시 중지해야 한다 | P1 |

---

## 8.5 포즈 추정

### 목적

사용자의 주요 관절 위치를 추정한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| POSE-001 | 앱은 어깨, 팔꿈치, 손목, 골반, 무릎, 발목 위치를 추정해야 한다 | P0 |
| POSE-002 | 앱은 각 landmark의 confidence를 확인해야 한다 | P0 |
| POSE-003 | confidence가 낮은 프레임은 분석에서 제외해야 한다 | P0 |
| POSE-004 | 앱은 오른손/왼손 기준으로 좌우 값을 정규화해야 한다 | P0 |
| POSE-005 | 앱은 프레임별 포즈를 PoseFrame 형태로 변환해야 한다 | P0 |
| POSE-006 | 앱은 일정 구간의 PoseFrame을 PoseSequence로 묶어 분석해야 한다 | P0 |

---

## 8.6 스윙 감지

### 목적

연속 프레임에서 실제 스윙 구간을 찾아낸다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| SWING-001 | 앱은 준비 상태와 스윙 상태를 구분해야 한다 | P0 |
| SWING-002 | 앱은 손목 속도, 어깨 회전 변화, 손목 이동량을 이용해 스윙 시작을 감지해야 한다 | P0 |
| SWING-003 | 앱은 손목 속도 감소와 follow-through 구간을 이용해 스윙 종료를 감지해야 한다 | P0 |
| SWING-004 | 앱은 너무 짧거나 불완전한 스윙을 분석 대상에서 제외해야 한다 | P0 |
| SWING-005 | 앱은 스윙 종료 후에만 음성 피드백을 출력해야 한다 | P0 |

---

## 8.7 자세 분석

### 목적

포핸드·백핸드의 대표 오류를 감지한다.

### 공통 분석 feature

```text
shoulderLineAngle
hipLineAngle
shoulderTurnRange
hipTurnRange
shoulderHipSeparation
wristVelocity
wristHeight
wristRelativeX
elbowAngle
kneeFlexion
bodyBalance
followThroughHeight
swingDuration
```

### 포핸드 오류

| 오류 ID | 오류명 | 감지 기준 예시 | 음성 큐 |
| --- | --- | --- | --- |
| FH-ERR-001 | 어깨 회전 부족 | backswing 구간의 어깨 회전량 부족 | “어깨 돌려” |
| FH-ERR-002 | 임팩트 위치가 늦음 | contact proxy에서 손목이 몸 중심보다 뒤쪽 | “앞에서 맞춰” |
| FH-ERR-003 | 팔로스루 부족 | contact 이후 손목 높이/이동량 부족 | “마무리 높게” |
| FH-ERR-004 | 하체 사용 부족 | 무릎 굴곡 변화와 중심 이동 부족 | “무릎 낮춰” |
| FH-ERR-005 | 몸통 회전 부족 | forward swing 중 어깨선 회전 변화 부족 | “몸통 써” |

### 백핸드 오류

MVP에서는 기본적으로 **양손 백핸드**를 기준으로 한다.

| 오류 ID | 오류명 | 감지 기준 예시 | 음성 큐 |
| --- | --- | --- | --- |
| BH-ERR-001 | 어깨 회전 부족 | backswing 구간의 어깨 회전량 부족 | “어깨 더” |
| BH-ERR-002 | 몸통 회전 부족 | forward swing 중 몸통 회전 변화 부족 | “몸통 먼저” |
| BH-ERR-003 | 손과 몸 사이 간격 부족 | contact proxy에서 손목-몸통 거리 부족 | “간격 유지” |
| BH-ERR-004 | 임팩트 위치가 늦음 | contact proxy가 몸 뒤쪽에서 발생 | “앞에서 맞춰” |
| BH-ERR-005 | 팔로스루 부족 | follow-through 구간 이동량 부족 | “끝까지” |

---

## 8.8 피드백 선택

### 목적

사용자에게 가장 중요한 하나의 피드백만 전달한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| CUE-001 | 앱은 한 스윙당 최대 1개의 음성 큐만 출력해야 한다 | P0 |
| CUE-002 | 앱은 오류 severity가 가장 높은 큐를 선택해야 한다 | P0 |
| CUE-003 | severity가 임계값보다 낮으면 피드백하지 않아야 한다 | P0 |
| CUE-004 | 동일 큐는 일정 시간 내 반복 출력되지 않아야 한다 | P0 |
| CUE-005 | 사용자는 피드백 빈도를 조절할 수 있어야 한다 | P1 |
| CUE-006 | 사용자는 음성 큐 언어와 음량을 설정할 수 있어야 한다 | P2 |

### 큐 선택 정책

```text
1. 현재 스윙에서 감지된 오류 목록 생성
2. 각 오류 severity 계산
3. 사용자의 최근 오류 히스토리 반영
4. 쿨다운 중인 큐 제외
5. 가장 severity가 높은 큐 선택
6. severity가 threshold 미만이면 침묵
7. 선택된 큐를 AudioFeedbackClient로 전달
```

---

## 8.9 오디오 피드백

### 목적

스윙 직후 AirPods 또는 현재 오디오 출력 장치로 짧은 큐를 전달한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| AUD-001 | 앱은 사전 정의된 짧은 음성 큐를 재생해야 한다 | P0 |
| AUD-002 | 피드백은 스윙 종료 직후 출력되어야 한다 | P0 |
| AUD-003 | 음성 큐 길이는 0.5~1.5초 수준이어야 한다 | P0 |
| AUD-004 | 재생 중 새 큐가 들어오면 중복 재생을 방지해야 한다 | P0 |
| AUD-005 | AirPods가 없더라도 iPhone 스피커 또는 현재 출력 장치로 재생되어야 한다 | P0 |
| AUD-006 | MVP에서는 TTS보다 사전 녹음 클립을 우선 사용한다 | P1 |

### 초기 음성 큐 목록

```text
포핸드:
  - 어깨 돌려
  - 앞에서 맞춰
  - 마무리 높게
  - 몸통 써
  - 무릎 낮춰

백핸드:
  - 어깨 더
  - 몸통 먼저
  - 간격 유지
  - 앞에서 맞춰
  - 끝까지

공통:
  - 좋아요
  - 다시 준비
  - 화면 안으로
  - 조금 뒤로
```

---

## 8.10 세션 요약

### 목적

실시간 중에는 짧게, 세션 종료 후에는 자세히 설명한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| SUM-001 | 세션 종료 후 전체 스윙 수를 보여줘야 한다 | P0 |
| SUM-002 | 분석 성공 스윙 수와 실패 스윙 수를 보여줘야 한다 | P0 |
| SUM-003 | 가장 많이 반복된 오류 3개를 보여줘야 한다 | P0 |
| SUM-004 | 다음 세션의 추천 집중 목표를 보여줘야 한다 | P0 |
| SUM-005 | 세션 기록은 로컬에 저장되어야 한다 | P0 |
| SUM-006 | 사용자는 세션 기록을 삭제할 수 있어야 한다 | P0 |

### 세션 요약 예시

```text
포핸드 세션 요약

총 스윙: 32회
분석 성공: 27회
분석 실패: 5회

반복 오류:
1. 임팩트 위치가 늦음: 13회
2. 어깨 회전 부족: 9회
3. 팔로스루 부족: 7회

다음 세션 목표:
“앞에서 맞춰” 하나에 집중하세요.
```

---

## 8.11 히스토리

### 목적

사용자가 이전 세션 기록을 확인한다.

### 요구사항

| ID | 요구사항 | 우선순위 |
| --- | --- | --- |
| HIST-001 | 사용자는 날짜별 세션 목록을 볼 수 있어야 한다 | P1 |
| HIST-002 | 사용자는 세션 상세 요약을 볼 수 있어야 한다 | P1 |
| HIST-003 | 사용자는 세션을 삭제할 수 있어야 한다 | P1 |
| HIST-004 | MVP에서는 원본 영상을 기본 저장하지 않는다 | P0 |
| HIST-005 | 사용자가 명시적으로 선택한 경우에만 영상 저장을 허용한다 | P2 |

---

## 9. 비기능 요구사항

## 9.1 성능

| 항목 | 목표 |
| --- | --- |
| 포즈 추정 처리 | 실시간 또는 준실시간 |
| 분석 지연 | 스윙 종료 후 0.3~1.0초 내 피드백 |
| UI 반응성 | 녹화 중에도 조작 지연 최소화 |
| 프레임 처리 | 최신 프레임 우선, 지연 프레임 폐기 |
| TCA Action 빈도 | 프레임 단위가 아닌 이벤트 단위 |
| 앱 시작 | 빠른 카메라 진입 우선 |

## 9.2 정확도

| 항목 | 목표 |
| --- | --- |
| 스윙 감지 성공률 | 내부 테스트 기준 80% 이상 |
| 포핸드/백핸드 모드 분석 성공률 | 내부 테스트 기준 80% 이상 |
| 대표 오류 cue 적합도 | 코치 검수 기준 70% 이상 |
| 잘못된 피드백률 | 초기 테스트에서 20% 이하 목표 |

## 9.3 안정성

| 항목 | 요구사항 |
| --- | --- |
| 카메라 권한 없음 | 앱이 크래시하지 않고 안내 화면 표시 |
| 신체 인식 실패 | “화면 안으로” 등 가이드 표시 |
| 오디오 출력 실패 | UI에만 cue 표시 |
| 장시간 세션 | 메모리 증가가 제한적이어야 함 |
| 백그라운드 전환 | 세션 일시정지 또는 종료 처리 |

## 9.4 개인정보

| 항목 | 결정 |
| --- | --- |
| 서버 업로드 | MVP에서는 없음 |
| 원본 영상 저장 | 기본 저장하지 않음 |
| 포즈 데이터 저장 | 세션 요약과 필요한 metric만 로컬 저장 |
| 삭제권 | 사용자가 로컬 데이터를 삭제 가능 |
| 향후 데이터 수집 | 명시적 동의 기반 |

---

## 10. 정보 구조

```text
App
├── Splash
├── Onboarding
│   ├── Handedness
│   ├── Backhand Type
│   ├── Audio Guide
│   └── Camera Guide
├── Main
│   ├── Start Training
│   ├── History
│   └── Settings
├── Training Setup
│   ├── Stroke Type
│   ├── Camera Mode
│   └── Body Detection Check
├── Record
│   ├── Camera Preview
│   ├── Skeleton Overlay
│   ├── Status Indicator
│   ├── Latest Cue
│   └── Stop Session
├── Session Summary
│   ├── Swing Count
│   ├── Error Ranking
│   ├── Recommended Focus
│   └── Save/Delete
├── History
└── Settings
```

---

## 11. 화면별 요구사항

## 11.1 Main 화면

### 목적

훈련 시작과 기록 접근.

### 구성

```text
- 오늘의 시작 버튼
- 최근 세션 요약
- 포핸드 빠른 시작
- 백핸드 빠른 시작
- 히스토리
- 설정
```

### Acceptance Criteria

```text
Given 사용자가 앱을 실행했을 때
When 온보딩이 완료되어 있다면
Then Main 화면으로 이동해야 한다.

Given 사용자가 "훈련 시작"을 누르면
Then TrainingSetupFeature로 이동해야 한다.
```

---

## 11.2 Training Setup 화면

### 목적

분석 조건 설정.

### 구성

```text
- 포핸드 / 백핸드 선택
- 측면 / 후방 대각선 촬영 선택
- 카메라 설치 예시 이미지 또는 안내
- 전신 인식 체크
- 시작 버튼
```

### Acceptance Criteria

```text
Given 사용자가 포핸드를 선택하고 카메라 품질 체크를 통과했을 때
When 시작 버튼을 누르면
Then Record 화면으로 이동해야 한다.

Given 전신이 화면에 들어오지 않을 때
Then 시작 버튼은 비활성화되거나 경고를 표시해야 한다.
```

---

## 11.3 Record 화면

### 목적

실시간 촬영과 피드백 제공.

### 구성

```text
- 카메라 preview
- 신체 인식 상태
- 선택 동작 표시
- 최신 cue 표시
- 스윙 수
- 종료 버튼
```

### Acceptance Criteria

```text
Given 사용자가 세션을 시작했을 때
When 스윙이 감지되고 분석이 완료되면
Then 앱은 최대 1개의 음성 cue를 출력해야 한다.

Given pose confidence가 낮을 때
When 분석이 불가능하면
Then 앱은 자세 오류 cue 대신 촬영 가이드를 표시해야 한다.

Given 동일 cue가 직전에 출력되었을 때
When 쿨다운 시간이 지나지 않았다면
Then 같은 cue를 다시 출력하지 않아야 한다.
```

---

## 11.4 Session Summary 화면

### 목적

세션 결과 확인.

### 구성

```text
- 전체 스윙 수
- 분석 성공률
- 주요 오류 순위
- 추천 집중 목표
- 저장 완료 상태
- 삭제 버튼
```

### Acceptance Criteria

```text
Given 사용자가 세션을 종료했을 때
Then 세션 요약 화면이 표시되어야 한다.

Given 세션에 분석 가능한 스윙이 없을 때
Then 앱은 “분석 가능한 스윙이 부족합니다” 메시지를 표시해야 한다.
```

---

## 12. 데이터 모델

## 12.1 UserProfile

```swift
struct UserProfile: Equatable, Codable {
    var id: UUID
    var handedness: Handedness
    var backhandType: BackhandType
    var skillLevel: SkillLevel?
    var feedbackFrequency: FeedbackFrequency
    var createdAt: Date
    var updatedAt: Date
}
```

## 12.2 TrainingSession

```swift
struct TrainingSession: Equatable, Codable, Identifiable {
    var id: UUID
    var strokeType: StrokeType
    var cameraMode: CameraMode
    var startedAt: Date
    var endedAt: Date?
    var swingEvents: [SwingEvent]
    var summary: SessionSummary?
}
```

## 12.3 SwingEvent

```swift
struct SwingEvent: Equatable, Codable, Identifiable {
    var id: UUID
    var strokeType: StrokeType
    var startedAt: TimeInterval
    var endedAt: TimeInterval
    var analysisResult: SwingAnalysisResult?
    var selectedCue: CoachingCue?
    var quality: AnalysisQuality
}
```

## 12.4 SwingAnalysisResult

```swift
struct SwingAnalysisResult: Equatable, Codable {
    var strokeType: StrokeType
    var detectedErrors: [DetectedError]
    var primaryError: DetectedError?
    var metrics: SwingMetrics
    var ruleVersion: RuleVersion
}
```

## 12.5 DetectedError

```swift
struct DetectedError: Equatable, Codable {
    var type: CoachingErrorType
    var severity: Double
    var cue: CoachingCue
    var phase: SwingPhase?
}
```

## 12.6 CoachingCue

```swift
struct CoachingCue: Equatable, Codable, Identifiable {
    var id: String
    var text: String
    var audioAssetName: String?
    var category: CoachingCueCategory
    var priority: Int
}
```

---

## 13. 아키텍처 요구사항

## 13.1 기본 방향

```text
SwiftUI + TCA + Clean Architecture + Tuist Modular Architecture
```

### 계층 역할

| 계층 | 역할 |
| --- | --- |
| App | 앱 조립, dependency injection, root navigation |
| Feature | 화면 상태, 사용자 액션, 화면 흐름 |
| Domain | 포즈, 스윙, 오류, 코칭 cue 관련 순수 모델과 규칙 |
| Core | 카메라, 포즈 추정, 오디오, 로컬 저장소 구현 |
| Shared | 공통 유틸, 로깅, dependency helper |
| UserInterface | 디자인 시스템, 공통 UI, 카메라 overlay |

---

## 13.2 추천 프로젝트 구조

```text
TennisCoach
├── Projects
│   ├── App
│   │   └── TennisCoachApp
│   │
│   ├── Feature
│   │   ├── AppFeature
│   │   ├── OnboardingFeature
│   │   ├── MainFeature
│   │   ├── TrainingSetupFeature
│   │   ├── RecordFeature
│   │   ├── SessionSummaryFeature
│   │   ├── HistoryFeature
│   │   └── SettingsFeature
│   │
│   ├── Domain
│   │   └── TennisDomain
│   │
│   ├── Core
│   │   ├── CameraClient
│   │   ├── CameraLive
│   │   ├── PoseEstimationClient
│   │   ├── PoseEstimationLive
│   │   ├── CoachingEngineClient
│   │   ├── CoachingEngineLive
│   │   ├── AudioFeedbackClient
│   │   ├── AudioFeedbackLive
│   │   ├── LocalSessionStoreClient
│   │   ├── LocalSessionStoreLive
│   │   └── PermissionClient
│   │
│   ├── Shared
│   │   ├── DependencyInjection
│   │   ├── Logger
│   │   └── Util
│   │
│   └── UserInterface
│       ├── DesignSystem
│       └── CameraPreviewUI
│
├── Plugin
├── Tuist
├── Scripts
├── XCConfig
├── Package.swift
├── Tuist.swift
└── Workspace.swift
```

---

## 13.3 의존성 방향

```text
App
↓
Feature
↓
Domain

Feature
↓
Core Client

App
↓
Core Live
```

### 금지 규칙

```text
Domain은 SwiftUI를 import하지 않는다.
Domain은 AVFoundation을 import하지 않는다.
Feature는 AVFoundation을 직접 import하지 않는다.
Feature는 MediaPipe 또는 Vision 구현체를 직접 알지 않는다.
Reducer는 매 프레임을 직접 처리하지 않는다.
TCA Action은 고수준 이벤트만 받는다.
```

---

## 13.4 실시간 파이프라인

```text
CameraLive
→ PoseEstimationLive
→ CoachingEngineLive
→ CoachingEvent
→ RecordFeature
→ AudioFeedbackClient
```

### TCA로 전달되는 이벤트

```swift
enum CoachingEvent: Equatable {
    case bodyDetected(Bool)
    case cameraQualityChanged(CameraQuality)
    case strokeStarted(StrokeType)
    case strokeFinished(SwingAnalysisResult)
    case cueSelected(CoachingCue)
    case sessionMetricUpdated(SessionMetric)
}
```

### 핵심 원칙

```text
카메라 프레임은 Core에서 처리한다.
포즈 추정 결과도 Core 내부에서 sequence로 관리한다.
Feature는 분석 결과와 UI 상태만 관리한다.
```

---

## 14. Core ML 전략

## 14.1 MVP

MVP에서는 Core ML을 필수로 사용하지 않는다.

```text
Pose Estimation:
  Apple Vision 또는 MediaPipe

Coaching:
  Rule-based

Stroke Selection:
  사용자 수동 선택
```

## 14.2 MVP 1.5

Core ML을 동작 분류에 사용한다.

```text
StrokeClassifier.mlmodel

입력:
  PoseSequence

출력:
  - forehand
  - twoHandBackhand
  - idle
  - other
```

## 14.3 MVP 이후

Core ML을 오류 분류에 사용한다.

```text
ErrorClassifier.mlmodel

입력:
  SwingMetrics 또는 PoseFeatureSequence

출력:
  - shoulderTurnLack
  - lateContact
  - poorFollowThrough
  - poorSpacing
  - insufficientBodyRotation
```

### ModelProvider 설계

```text
초기:
  BundledModelProviderLive

향후:
  RemoteModelProviderLive
```

---

## 15. 로컬 저장 전략

## 15.1 MVP 저장 대상

저장한다.

```text
- UserProfile
- TrainingSession metadata
- SwingEvent summary
- DetectedError count
- SelectedCue history
- RuleVersion
```

기본 저장하지 않는다.

```text
- 원본 영상
- 전체 프레임 이미지
- 민감한 신체 영상 데이터
```

선택적으로 저장한다.

```text
- 사용자가 명시적으로 저장한 짧은 클립
- 디버그용 pose sequence
```

## 15.2 향후 플랫폼 확장 대비

```text
LocalSessionStoreClient
RemoteSessionStoreClient

LocalRuleConfigClient
RemoteRuleConfigClient

BundledModelProviderClient
RemoteModelProviderClient
```

MVP에서는 전부 Local/Bundled 구현체만 사용한다.

---

## 16. 개인정보 및 데이터 정책

### MVP 정책

1. 앱은 백엔드 없이 동작한다.
2. 영상은 기본적으로 서버에 업로드되지 않는다.
3. 원본 영상은 기본 저장하지 않는다.
4. 세션 요약과 분석 metric만 로컬에 저장한다.
5. 사용자는 언제든 로컬 데이터를 삭제할 수 있다.
6. 향후 데이터 기반 개선 기능은 명시적 opt-in 방식으로 제공한다.

### 향후 데이터 수집 opt-in 문구 방향

```text
자세 분석 성능 개선을 위해 익명화된 포즈 데이터와 세션 분석 결과를 제공할 수 있습니다.
원본 영상은 별도 동의 없이 업로드되지 않습니다.
언제든 설정에서 데이터 제공을 중단할 수 있습니다.
```

---

## 17. 성공 지표

백엔드가 없는 MVP에서는 서버 analytics를 쓰지 않으므로, 초기에는 사용자 인터뷰와 로컬 테스트 중심으로 검증한다.

### 제품 지표

| 지표 | 목표 |
| --- | --- |
| 첫 세션 완료율 | 60% 이상 |
| 첫 세션 중 스윙 10회 이상 수행 비율 | 50% 이상 |
| 세션 후 “피드백이 유용했다” 응답 | 60% 이상 |
| 피드백이 방해된다고 응답한 비율 | 30% 이하 |
| 7일 내 재사용률 | 초기 테스트에서 관찰 지표 |
| 동일 오류 반복 감소 | 세션 내 후반부에서 감소 추세 확인 |

### 기술 지표

| 지표 | 목표 |
| --- | --- |
| 분석 성공률 | 80% 이상 |
| 포즈 인식 실패율 | 20% 이하 |
| 스윙 감지 실패율 | 20% 이하 |
| 잘못된 cue 체감률 | 20% 이하 |
| 크래시 없는 세션 비율 | 95% 이상 |
| 스윙 종료 후 피드백 지연 | 1초 이내 |

---

## 18. 테스트 계획

## 18.1 Unit Test

| 테스트 | 대상 |
| --- | --- |
| ForehandRuleSetTests | 포핸드 오류 판정 |
| BackhandRuleSetTests | 백핸드 오류 판정 |
| SwingPhaseDetectionTests | 스윙 시작/종료 감지 |
| CueSelectionPolicyTests | cue 우선순위와 쿨다운 |
| SessionSummaryTests | 오류 집계와 추천 목표 |
| UserProfileTests | 좌우잡이 정규화 |

## 18.2 Feature Test

| 테스트 | 대상 |
| --- | --- |
| OnboardingFeatureTests | 초기 설정 저장 |
| TrainingSetupFeatureTests | 촬영 조건 체크 |
| RecordFeatureTests | CoachingEvent 처리 |
| SessionSummaryFeatureTests | 세션 결과 표시 |
| SettingsFeatureTests | 피드백 빈도 변경 |

## 18.3 현장 테스트

| 조건 | 확인 항목 |
| --- | --- |
| 실내 코트 | 조명, 배경, 포즈 인식 |
| 야외 코트 | 역광, 그림자, 흔들림 |
| 흰 옷/검은 옷 | 관절 추정 안정성 |
| 초보자 스윙 | 오류 감지 |
| 중급자 스윙 | 과도한 피드백 여부 |
| 오른손/왼손 | 좌우 정규화 |
| 포핸드/백핸드 | 동작별 rule 차이 |
| AirPods 연결/미연결 | 오디오 출력 |

---

## 19. 리스크와 대응

| 리스크 | 설명 | 대응 |
| --- | --- | --- |
| 포즈 추정 정확도 부족 | 테니스는 움직임이 빠르고 라켓/팔 가림이 많음 | 촬영 모드 제한, confidence 기반 필터링 |
| 잘못된 피드백 | 사용자가 신뢰를 잃을 수 있음 | severity threshold 높게 설정, 침묵 허용 |
| 음성 피드백 과다 | 스윙 리듬 방해 | 스윙당 1개, 쿨다운, 빈도 설정 |
| 촬영 환경 편차 | 실내/야외/각도에 따라 성능 차이 | 설치 가이드와 품질 체크 강화 |
| 한손/양손 백핸드 혼동 | 기준이 달라 오류 판정이 흔들림 | MVP는 양손 백핸드 기준 |
| TCA 과부하 | 매 프레임 action 전달 시 성능 저하 | Core에서 프레임 처리, Feature에는 이벤트 전달 |
| 개인정보 우려 | 카메라 기반 앱에 대한 거부감 | 온디바이스, 원본 영상 미저장, 명확한 안내 |

---

## 20. 출시 기준

MVP를 TestFlight로 배포하기 위한 최소 기준.

```text
기능:
  - 온보딩 완료 가능
  - 포핸드 세션 시작/종료 가능
  - 백핸드 세션 시작/종료 가능
  - 실시간 포즈 인식 가능
  - 스윙 감지 가능
  - 스윙 직후 음성 cue 출력 가능
  - 세션 요약 저장 가능
  - 로컬 기록 삭제 가능

품질:
  - 주요 화면 크래시 없음
  - 카메라 권한 거부 케이스 처리
  - 포즈 인식 실패 케이스 처리
  - AirPods 미연결 케이스 처리
  - 10분 세션에서 메모리 급증 없음

제품:
  - 촬영 가이드 제공
  - 개인정보 안내 제공
  - MVP 외 기능이 과도하게 노출되지 않음
```

---

## 21. 로드맵

## Phase 0 — Prototype

목표: 기술 가능성 검증.

```text
- 카메라 preview
- 포즈 추정 연결
- 주요 관절 좌표 추출
- 포핸드/백핸드 수동 모드 선택
- 단일 rule 기반 cue 출력
```

## Phase 1 — MVP

목표: 실제 사용 가능한 온디바이스 코칭 앱.

```text
- Onboarding
- Training Setup
- Record
- Audio Feedback
- Session Summary
- History
- Local Storage
- Forehand 3~5개 오류
- Two-hand Backhand 3~5개 오류
```

## Phase 1.5 — Core ML 분류

목표: 수동 설정을 줄이고 분석 안정성 개선.

```text
- StrokeClassifier.mlmodel
- forehand / backhand / idle / other 자동 분류
- ErrorClassifier 실험
- Rule threshold 개인화
```

## Phase 2 — 데이터 기반 개선

목표: 사용자 데이터로 코칭 품질 개선.

```text
- 데이터 제공 opt-in
- 익명화된 pose metric 수집
- RemoteRuleConfig
- RemoteModelProvider
- 모델 버전 관리
- 코치 라벨링 도구
```

## Phase 3 — 코칭 플랫폼

목표: 개인화·코치 연동·구독 모델.

```text
- 계정
- 클라우드 세션 동기화
- 코치 리뷰
- 영상 클립 공유
- 사용자별 개선 추세
- 유료 코칭 리포트
- 공/라켓/코트 추적
```

---

## 22. 최종 MVP 정의

```text
TennisCoach MVP는 백엔드 없이 동작하는 iOS 앱이다.

사용자는 iPhone을 삼각대에 고정하고 포핸드 또는 양손 백핸드 연습을 시작한다.
앱은 카메라로 신체 포즈를 추정하고, 스윙 종료 직후 가장 중요한 자세 오류 1개를 AirPods로 알려준다.
세션 종료 후 앱은 반복 오류와 다음 연습 목표를 로컬에 저장하고 보여준다.

MVP의 핵심 가치는 많은 정보를 주는 것이 아니라,
사용자가 다음 스윙에서 바로 고칠 수 있는 하나의 cue를 제공하는 것이다.
```

---

## 23. 핵심 결정 요약

| 항목 | 결정 |
| --- | --- |
| 백엔드 | MVP에서는 없음 |
| 플랫폼 | iOS 우선 |
| UI | SwiftUI |
| 상태 관리 | TCA |
| 아키텍처 | Tuist 기반 모듈화 + Clean Architecture |
| 포즈 추정 | Apple Vision 우선, MediaPipe 대안 |
| Core ML | 초기 필수 아님, 이후 분류기에 사용 |
| 분석 | Rule-based 우선 |
| 피드백 | 스윙당 최대 1개 음성 cue |
| 지원 동작 | 포핸드, 양손 백핸드 |
| 저장 | 로컬 세션 요약 중심 |
| 개인정보 | 원본 영상 기본 미저장 |
| 확장 방향 | 데이터 기반 코칭 플랫폼 |

다음 산출물로는 이 PRD를 기준으로 **Tuist 모듈 정의서 + TCA Feature 설계서 + 1차 개발 태스크 백로그**를 만드는 것이 좋습니다.
